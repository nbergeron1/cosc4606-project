<template>
  <!-- A box that has an image, buttons, and a title beneath it.-->
  <Card
    style="
      width: 15rem;
      height: 22rem;
      margin-top: 2rem;
      position: relative;
      overflow: hidden;
    "
    class="hover:shadow-2xl hover:scale-105 transition-transform transition-shadow duration-300"
    @click="openPopup"
  >
    <template #header>
      <img
        alt="alt"
        :src="image"
        style="height: 10rem; width: 15rem; border-radius: 1rem"
      />
      <div
        v-if="onSale"
        :style="{
          padding: `0.3rem ${Math.max(4, 5 - dealDescription.length * 0.5)}rem`,
        }"
        class="absolute top-[4.5rem] left-[-2rem] bg-red-500 text-white text-xs font-bold transform -rotate-[35deg] origin-top-left overflow-hidden"
      >
        {{ discount * 100 }}% OFF
      </div>
    </template>
    <template #title>{{ title }}</template>
    <template #content>
      <div style="height: 4rem; overflow-y: hidden">
        <p class="m-0 text-sm">
          {{ description }}
        </p>
      </div>
    </template>
    <template #footer>
      <div class="flex gap-2 mt-1 h-8">
        <Button
          label="Add to cart"
          severity="contrast"
          outlined
          class="w-full"
        />
      </div>
    </template>
  </Card>
  <Dialog
    v-model:visible="showPopup"
    :header="title"
    :modal="true"
    :closable="true"
    :style="{ width: '33vw' }"
    @hide="closePopup"
  >
    <div class="p-4">
      <!-- Display the image, title, and description of the item -->
      <img
        :src="image"
        :alt="title"
        class="w-[32rem] max-h-[16rem] h-auto rounded-lg mx-auto mb-4 object-cover"
      />

      <p class="text-lg mt-2">
        {{ description }}
      </p>
      <br />

      <Rating v-model="ratingAverage" readonly @click="openReviewPopup" />

      <Divider class="mt-4" />

      <p class="text-lg mt-2">
        <strong>Ingredients:</strong> {{ ingredients }}
      </p>
      <p class="text-lg mt-2">
        <strong>Nutritional Info:</strong> {{ nutritionalInfo }}
      </p>
      <p v-if="allergyInfo" class="text-lg mt-2">
        <strong>Contains:</strong> {{ allergyInfo }}
      </p>
      <div class="flex flex-col gap-2 mt-2 mb-4">
        <div
          v-if="spiceLevel && spiceLevel !== 'None'"
          class="flex items-center"
        >
          <p class="text-lg mr-2"><strong>Spice Level:</strong></p>
          <Tag
            icon="pi pi-exclamation-triangle"
            :value="spiceLevel"
            severity="danger"
          ></Tag>
        </div>
        <div class="flex items-center">
          <p class="text-lg mr-2"><strong>Price:</strong></p>
          <Tag icon="pi pi-dollar" :value="price"></Tag>
        </div>

        <!-- Show leaf and seedling icon if veggy / vegan -->
        <div class="flex justify-end gap-2 mr-2">
          <!-- font awesome -->
          <font-awesome-icon
            v-if="IsVegan"
            icon="fas fa-seedling"
            class="text-green-500"
          />
          <font-awesome-icon
            v-if="IsVegetarian"
            icon="fas fa-leaf"
            class="text-green-500"
          />
        </div>
      </div>

      <!-- Count -->
      <InputGroup class="mt-2">
        <Button
          icon="pi pi-minus"
          style="background-color: #4b5563; border: #4b5563"
          @click="decrementCount"
        />
        <!-- Display the count of the item -->
        <InputText v-model="localCount" class="text-center w-12" />
        <Button
          icon="pi pi-plus"
          style="background-color: #4b5563; border: #4b5563"
          @click="incrementCount"
        />
      </InputGroup>
    </div>
  </Dialog>

  <Dialog
    v-model:visible="showReviewPopup"
    :header="title"
    :modal="true"
    :closable="true"
    :style="{ width: '33vw', height: '90vh', overflowY: 'auto' }"
    @hide="closeReviewPopup"
  >
    <div class="p-4">
      <!-- Option to leave own rating -->

      <h2 class="text-xl">Leave a Review</h2>
      <Divider class="mt-2" />
      <div class="flex flex-col gap-2 mb-4">
        <Editor name="content" editorStyle="height: 120px" />
        <div class="flex items-center gap-2">
          <label class="text-lg">Leave Star Rating:</label>
          <Rating v-model="userRating" />
        </div>
        <Button @click="insertNewRating" severity="contrast" label="Add Review" outlined />
      </div>

      <h2 class="text-xl">Other Reviews</h2>
      <Divider class="mt-2" />
      <div class="flex flex-col gap-2 mt-2">
        <div v-if="allRatings.length === 0">
          <p class="text-sm italic">Looks like no one has left a review... Be the first!</p>
        </div>
        <div v-else>
          <div v-for="rating in allRatings" :key="rating.RatingID">
            <div class="flex items-center gap-2">
              <Rating v-model="rating.Rating" readonly />
              <p class="text-lg">{{ rating.Comment }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Dialog>
</template>

<script setup>
import { defineProps, ref, watch, defineEmits } from "vue";
import Card from "primevue/card";
import Button from "primevue/button";
import InputGroup from "primevue/inputgroup";
import InputText from "primevue/inputtext";
import Dialog from "primevue/dialog";
import Tag from "primevue/tag";
import Divider from "primevue/divider";
import Rating from "primevue/rating";
import Editor from "primevue/editor";
import { useToast } from "primevue/usetoast";

import { getRatings, addRating } from "../data/database";

const props = defineProps({
  menuID: Number,
  image: String,
  title: String,
  filters: Array,
  count: Number,
  description: String,
  avgRating: Number,
  ingredients: String,
  nutritionalInfo: String,
  allergyInfo: String,
  IsVegan: Boolean,
  IsVegetarian: Boolean,
  spiceLevel: String,
  onSale: Boolean,
  discount: Number,
  dealDescription: String,
  price: Number,
});

const toast = useToast();

const ratingAverage = ref(props.avgRating);
const allRatings = ref([]);
const userRating = ref(0);

const showPopup = ref(false);
const showReviewPopup = ref(false);

// Popup
function openPopup() {
  showPopup.value = true;
}

// Popup
async function openReviewPopup() {
  // Get all the ratings for this item
  console.log("Menu ID:", props.menuID);
  allRatings.value = await getRatings(props.menuID);

  showReviewPopup.value = true;
}

// Popup close
function closeReviewPopup() {
  showReviewPopup.value = false;
}

function buttonClose() {
  showPopup.value = false;
}

// Popup close
function closePopup() {
  // make sure you aren't clicking inside the pop up box
  if (event.target.classList.contains("item_box_popup"))
    showPopup.value = false;
  return;
}

const insertNewRating = async () => {
  // Make sure that the star rating was selected
  if (userRating.value === 0) {
    toast.add({
      severity: "error",
      summary: "Error",
      detail: "Please select a star rating.",
      life: 3000,
    });
    return;
  }
  // Add the rating to the database
  console.log("Adding rating:", userRating.value);
  // Comment
  const comment = document.querySelector(".ql-editor").innerText;
  console.log("Comment:", comment);

  await addRating({
    MenuID: props.menuID,
    CustomerID: JSON.parse(document.cookie.split('; ').find(row => row.startsWith('user='))?.split('=')[1] || '{}').CustomerID || '',
    Rating: userRating.value,
    Comment: comment,
    ReviewDate: new Date().toISOString().slice(0, 19).replace('T', ' '),
  });

  toast.add({
    severity: "success",
    summary: "Success",
    detail: "Rating added successfully.",
    life: 3000,
  });

  // Update the ratings
  allRatings.value = await getRatings(props.menuID);

  // Close the dialog
  closeReviewPopup();
};

const emit = defineEmits(); // Define emit to access the emit function

// The local count for the buttons
const localCount = ref(
  JSON.parse(localStorage.getItem("order") || "[]").find(
    (item) => item.title === props.title
  )?.count ||
    props.count ||
    0
);

// The count for the popup increment/decrement buttons
function incrementCount() {
  localCount.value++;
  emit("count-updated", {
    title: props.title,
    price: props.price,
    count: localCount.value,
  });
}

function decrementCount() {
  if (localCount.value > 0) {
    localCount.value--;
    emit("count-updated", {
      title: props.title,
      price: props.price,
      count: localCount.value,
    });
  }
}

// Watch for changes in the count prop from the parent
watch(
  () => props.count,
  (newCount) => {
    localCount.value = newCount;
  }
);
</script>
