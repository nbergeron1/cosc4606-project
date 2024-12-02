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
              <span class="pending_count">{{ item.count }}x</span>
              {{ capitalizeFirstLetter(item.title) }}
            </p>
            <div class="flex items-center">
              <p class="text-lg text-black font-md ml-2">
                ${{ item.price.toFixed(2) }}
              </p>
              <font-awesome-icon
                icon="fas fa-check"
                class="text-green-300 text-lg ml-2"
              />
            </div>
          </div>
        </template>

        <template #footer>
          <Tag
            icon="pi pi-dollar"
            :value="'Total: ' + orderItem.TotalAmount.toFixed(2)"
            severity="info"
            style="font-size: 0.75rem"
          />
          <div class="text-black text-xs mt-2">
            Placed on
            {{
              new Date(orderItem.OrderDate).toLocaleString("en-GB", {
                timeZone: "America/Toronto",
                day: "2-digit",
                month: "2-digit",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit",
                hour12: true,
              })
            }}
          </div>
        </template>
      </Card>
    </div>
  </ScrollPanel>
</template>

<script setup>
import { defineProps, ref, onMounted } from "vue";

import ScrollPanel from "primevue/scrollpanel";
import Card from "primevue/card";
import Tag from "primevue/tag";

const props = defineProps({
  order: Array,
});

// Format the timestamp to a 12-hour format
function formatTimestamp(timestamp) {
  const date = new Date(timestamp);
  const hours = date.getHours();
  const minutes = String(date.getMinutes()).padStart(2, "0");
  const seconds = date.getSeconds();
  const ampm = hours >= 12 ? "PM" : "AM";

  // Convert hours to 12-hour format
  const formattedHours = hours % 12 || 12;

  return `${formattedHours}:${minutes} ${ampm}`;
}

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
</script>
