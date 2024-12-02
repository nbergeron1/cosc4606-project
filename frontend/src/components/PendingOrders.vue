<template>
  <!-- A count of the number of items inside of the order. -->
  <div
    :class="{
      'flex justify-end mb-2': order.length > 0,
      'flex justify-center mb-2': order.length === 0,
    }"
  >
    <p v-if="order.length === 0" class="text-sm text-red-400 text-center">
      Order empty! Add something to your order first!
    </p>

    <p v-else class="text-sm text-black">Total Items: {{ order.length }}</p>
  </div>
  <!--
        Display the items in the order
    -->
  <div
    v-for="item in order"
    :key="item.id"
    class="flex justify-between items-center mb-2"
  >
    <p class="text-lg text-black font-md">
      {{ capatalizeFirstLetter(item.title) }}
    </p>
    <div class="flex items-center gap-2">
      <p class="pending_count">{{ item.count }}</p>
      <button class="pending_button" @click="decrementCount(item)">
        <font-awesome-icon class="text-md py-0.5" icon="fa-solid fa-minus" />
      </button>
      <button class="pending_button" @click="incrementCount(item)">
        <font-awesome-icon class="text-md py-0.5" icon="fa-solid fa-plus" />
      </button>
      <!-- Total cost -->
      <Tag
        icon="pi pi-dollar"
        :value="item.price * item.count"
        severity="info"
        rounded
      />
    </div>
  </div>
  <!-- Send to kitchen button -->
  <div class="flex justify-center mt-8">
    <Button
      :label="order.length === 0 ? 'Open Menu' : 'Place Order'"
      :icon="order.length > 0 ? 'pi pi-check-circle' : 'pi pi-book'"
      class="p-button-rounded p-button-sm"
      @click="order.length === 0 ? $router.push('/Menu') : placeOrder()"
    />
  </div>
</template>

<script setup lang="jsx">
import { defineProps, ref, getCurrentInstance, defineEmits } from "vue";
import { useRouter } from "vue-router";
import Button from "primevue/button";
import Tag from "primevue/tag";
import { addOrder, getOrderNumber } from "../data/database";

const router = useRouter();

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

const emits = defineEmits(["orderPlaced"]);

const props = defineProps({
  order: Array,
});

// Make the order array reactive
const order = ref(props.order);

// modify order to nopt include any items with a count of 0
order.value = order.value.filter((item) => item.count > 0);

function incrementCount(item) {
  item.count++;
  updateLocalStorage(item);
}

function decrementCount(item) {
  if (item.count > 0) {
    item.count--;
    updateLocalStorage(item);
  }

  // if the count is 0, remove the item from the order
  for (let i = order.value.length - 1; i >= 0; i--) {
    if (order.value[i].count === 0) {
      order.value.splice(i, 1);
    }
  }

  // print the order to the console
  console.log(order.value);
}

function capatalizeFirstLetter(string) {
  return string.replace(/(^|\s)\S/g, (match) => match.toUpperCase());
}

function updateLocalStorage(item) {
  let orderValue = JSON.parse(localStorage.getItem("order") || "[]");
  item.title = item.title.charAt(0).toLowerCase() + item.title.slice(1);
  const orderIndex = orderValue.findIndex(
    (orderItem) => orderItem.title === item.title
  );
  if (orderIndex !== -1) {
    orderValue[orderIndex].count = item.count;
    // recapitalize the first letter of each word
    item.title = item.title.charAt(0).toUpperCase() + item.title.slice(1);
    localStorage.setItem("order", JSON.stringify(orderValue));
  }
  // update the count in the template to reflect the change
  item.count = parseInt(item.count);
}

const { emit } = getCurrentInstance();

// When place order is clicked, clear the order from local storage and add the order to a new array called active orders
async function placeOrder() {
  let orderValue = JSON.parse(localStorage.getItem("order") || "[]");
  let activeOrders = JSON.parse(localStorage.getItem("activeOrders") || "[]");
  let completedOrders = JSON.parse(
    localStorage.getItem("completedOrders") || "[]"
  );
  const newIndex = completedOrders.length + activeOrders.length + 1;
  const timestamp = new Date().toISOString(); // Get the current timestamp

  const calculateGrandTotal = orderValue.reduce((acc, item) => {
    return acc + item.price * item.count;
  }, 0);

  // if the count is 0, remove the item from the order
  for (let i = orderValue.length - 1; i >= 0; i--) {
    if (orderValue[i].count === 0) {
      orderValue.splice(i, 1);
    }
  }

  const getHighestOrderNumber = await getOrderNumber();
  const nextOrderNumber = getHighestOrderNumber.HighestOrderID + 1;

  // prepare payload for both local storage and database (if guest, CustomerID is 0)
  const payload = {
    OrderID: nextOrderNumber,
    CustomerID: user.CustomerID ? user.CustomerID : null,
    GuestID: user.CustomerID ? null : user.GuestID,
    LocationID: parseInt(localStorage.getItem("location")[0]),
    TotalAmount: calculateGrandTotal,
    OrderStatus: "Pending",
    OrderType: localStorage.getItem("diningOption"),
    OrderData: JSON.stringify(orderValue),
    OrderDate: timestamp,
  };

  console.log("Payload:", payload);

  activeOrders.push(payload); // Add the timestamp to the activeOrders array

  // Add order as pending
  addOrder(payload);

  // Add the order to the active orders
  localStorage.setItem("activeOrders", JSON.stringify(activeOrders));

  localStorage.setItem("order", JSON.stringify([]));
  order.value = [];
  emit("orderPlaced");
}
</script>
