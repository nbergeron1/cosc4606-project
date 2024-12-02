<template>
<ScrollPanel
    style="height: 70vh"
    :dt="{
        bar: {
            background: '{primary.contrast}'
        }
    }"
>
    <div
      v-for="orderItem in order.slice().sort((a, b) => b.OrderID - a.OrderID)"
      :key="orderItem.OrderID"
      class="mb-2"
    >
      <Card
        style="background-color: #f1f5f9"
        class="border-2 rounded-xl mt-2 p-2"
      >
        <template #title>
          <p class="text-xl text-black font-semibold">
            Order #{{ orderItem.OrderID }}
          </p>
        </template>

        <template #content>
          <div
            v-for="item in parseOrderData(orderItem.OrderData)"
            :key="item.title"
            class="flex justify-between items-center"
          >
            <p class="text-lg text-black font-md">
              <span class="pending_count"
                >{{ item.count }}x</span
              >
              {{ capitalizeFirstLetter(item.title) }}
            </p>
            <div class="flex items-center">
              <p class="text-lg text-black font-md ml-2">
                ${{ item.price.toFixed(2) }}
              </p>
              <font-awesome-icon
                icon="fas fa-clock"
                class="text-gray-600 text-lg ml-2"
              />
            </div>
          </div>
        </template>

        <template #footer>
          <div class="text-black text-xs mt-2">
            Order placed
            {{ timeSinceOrder(orderItem.OrderDate) }} ago
          </div>
        </template>
      </Card>
    </div>
  </ScrollPanel>
</template>

<script setup>
import {
  defineProps,
  ref,
  onMounted,
  getCurrentInstance,
  defineEmits,
} from "vue";

import Card from "primevue/card";
import ScrollPanel from "primevue/scrollpanel";

const props = defineProps({
  order: Array,
});

function parseOrderData(orderData) {
  try {
    console.log("OrderData:", orderData);
    return JSON.parse(orderData);
  } catch (e) {
    console.error("Invalid JSON format for OrderData", e);
    return [];
  }
}

// Capatalize the first letter of each word in the title
function capitalizeFirstLetter(string) {
  return string.replace(/(^|\s)\S/g, (match) => match.toUpperCase());
}

function timeSinceOrder(orderDate) {
  const date = new Date(orderDate);
  const now = new Date(new Date().toLocaleString("en-US", { timeZone: "UTC" }));
  console.log('Order Date:', date);
  console.log('Now:', now);
  const diff = now - date;
  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  console.log("Seconds:", seconds);
  console.log("Minutes:", minutes);
  console.log("Hours:", hours);
  console.log("Days:", days);


  if (days > 0) {
    return `${days} day${days > 1 ? "s" : ""}`;
  } else if (hours > 0) {
    return `${hours} hour${hours > 1 ? "s" : ""}`;
  } else if (minutes > 0) {
    return `${minutes} minute${minutes > 1 ? "s" : ""}`;
  } else {
    return `${seconds} second${seconds > 1 ? "s" : ""}`;
  }
}
</script>
