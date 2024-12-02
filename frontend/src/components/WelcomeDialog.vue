<script setup>
import { onMounted, ref } from "vue";
import Dialog from "primevue/dialog";
import Button from "primevue/button";
import Select from "primevue/select";
import Tag from "primevue/tag";
import { useToast } from "primevue/usetoast";
import { useRouter } from "vue-router";

const router = useRouter();

const toast = useToast();

import { getLocations } from "../data/database";

const selectedLocation = ref();
const selectedDiningOption = ref();

const getLoggedInUserFromCookie = () => {
  // Return null if no user cookie is found
  if (
    !document.cookie.split(";").some((item) => item.trim().startsWith("user="))
  ) {
    return null;
  }
  const cookie = document.cookie
    .split("; ")
    .find((row) => row.startsWith("user="))
    .split("=")[1];
  console.log(cookie ? JSON.parse(decodeURIComponent(cookie)) : null);
  return cookie ? JSON.parse(decodeURIComponent(cookie)) : null;
};

const user = getLoggedInUserFromCookie();
const userName = user ? user.Name : "Guest";

const locations = ref([]);
const locationOptions = ref([]);


const diningOptions = ref([
  { name: "Dine In", code: "DI" },
  { name: "Take Out", code: "TO" },
]);

onMounted(async () => {
  // Load locations
  locations.value = await getLocations();
  if (locations.value.length > 0) {
    selectedLocation.value = locations.value[0];
  }
  // format the location options
    locationOptions.value = locations.value.map((location) => ({
        name: location.Address,
        code: location.LocationID,
    }));
});

const saveLocationAndDiningOption = () => {
  // Save the selected location and dining option to local storage
  localStorage.setItem("location", [
    selectedLocation.value.code,
    selectedLocation.value.name,
  ]);
  localStorage.setItem("diningOption", selectedDiningOption.value.name);
};

const props = defineProps({
  visible: Boolean,
});

const goToHome = () => {
    // Are both location and dining option selected?
    if (!selectedLocation.value || !selectedDiningOption.value) {
        toast.add({
            severity: "error",
            summary: "Error",
            detail: "Please select both location and dining option",
        });
        return;
    }
  saveLocationAndDiningOption();

  router.push({ path: "/Menu" });
};
</script>

<template>
  <div class="card flex justify-center">
    <Dialog
      v-model:visible="props.visible"
      modal
      header="Edit Profile"
      :style="{ width: '25rem' }"
    >
      <template #header>
        <div class="inline-flex items-center justify-center gap-2">
          <span class="font-bold whitespace-nowrap"
            >Welcome, {{ userName }}</span
          >
        </div>
      </template>
      <span class="text-surface-500 dark:text-surface-400 block mb-8"
        >We're looking forward to serving you. Before we get started, please
        select the location and dining option. Once selected, click on
        <Tag value="I'm Ready"></Tag>
      </span>
      <div class="flex items-center gap-4 mb-4">
        <Select
          v-model="selectedLocation"
          :options="locationOptions"
          optionLabel="name"
          placeholder="Please select your location..."
          class="w-full"
        />
      </div>
      <div class="flex items-center gap-4 mb-2">
        <Select
          v-model="selectedDiningOption"
          :options="diningOptions"
          optionLabel="name"
          placeholder="Please select your dining option..."
          class="w-full"
        />
      </div>
      <template #footer>
        <Button
          label="I'm Ready"
          outlined
          severity="success"
          @click="goToHome"
          autofocus
        />
      </template>
    </Dialog>
  </div>
</template>
