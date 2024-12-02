<script setup>
import { onMounted, ref } from "vue";
import Header from "../components/Header.vue";
import Draggable from "vuedraggable";

import Divider from "primevue/divider";
import Tag from "primevue/tag";

import { updateOrderStatus, getOrdersByStatus } from "../data/database";
import { FontAwesomeIcon } from "@fortawesome/vue-fontawesome";

const PendingOrdersMounted = ref([]);
const CompletedOrdersMounted = ref([]);

onMounted(async () => {
  PendingOrdersMounted.value = await getOrdersByStatus("Pending");
  CompletedOrdersMounted.value = await getOrdersByStatus("Completed");
  checkOverdueOrders();

  setInterval(checkOverdueOrders, 60000);
});

const handleDragEnd = (event) => {
  console.log("Drag end event:", event);

  // Get the OrderID of the dragged item
  const item = event.item._underlying_vm_;

  // Is the item being dragged to the kitchen (pending orders)?
  if (event.to.id === "kitchen") {
    //console.log("Moved to kitchen:", item);
    //// Find the specific order in local storage (completed orders) and change it's status to 'Pending'
    //const completedOrders = JSON.parse(
    //  localStorage.getItem("completedOrders") || "[]"
    //);
    //const index = completedOrders.findIndex(
    //  (order) => order.OrderID === item.OrderID
    //);
    //console.log("Index:", index);
    //if (index !== -1) {
    //  // Remove the order from the completed orders
    //  completedOrders.splice(index, 1);
    //  localStorage.setItem("completedOrders", JSON.stringify(completedOrders));

    //  // Add the order to the pending orders
    //  const pendingOrders = JSON.parse(
    //    localStorage.getItem("activeOrders") || "[]"
    //  );
    //  pendingOrders.push(item);
    //  // Update the status of the order
    //  pendingOrders[pendingOrders.length - 1].OrderStatus = "Pending";
    //  localStorage.setItem("activeOrders", JSON.stringify(pendingOrders));

    // Update the order status in the database
    updateOrderStatus(item.OrderID, "Pending");
    //}
  } else {
    //nsole.log("Moved to done:", item);
    // Find the specific order in local storage (pending orders) and change it's status to 'Completed'
    //nst pendingOrders = JSON.parse(
    //localStorage.getItem("activeOrders") || "[]"
    //
    //nst index = pendingOrders.findIndex(
    //(order) => order.OrderID === item.OrderID
    //
    //nsole.log("Index:", index);
    // (index !== -1) {
    //// Remove the order from the pending orders
    //pendingOrders.splice(index, 1);
    //localStorage.setItem("activeOrders", JSON.stringify(pendingOrders));

    //// Add the order to the completed orders
    //const completedOrders = JSON.parse(
    //  localStorage.getItem("completedOrders") || "[]"
    //);
    //completedOrders.push(item);
    //// Update the status of the order
    //completedOrders[completedOrders.length - 1].OrderStatus = "Completed";
    //localStorage.setItem("completedOrders", JSON.stringify(completedOrders));

    //// Update the order status in the database
    //console.log("Updating order status to Completed:", item.OrderID);
    updateOrderStatus(item.OrderID, "Completed");
    //}
  }
};

function timeSinceOrder(orderDate) {
  const date = new Date(orderDate);
  const now = new Date(new Date().toLocaleString("en-US", { timeZone: "UTC" }));
  console.log("Order Date:", date);
  console.log("Now:", now);
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

function parseOrderData(orderData) {
  try {
    console.log("OrderData:", orderData);
    return JSON.parse(orderData);
  } catch (e) {
    console.error("Invalid JSON format for OrderData", e);
    return [];
  }
}

function checkOverdueOrders() {
  const now = new Date(new Date().toLocaleString("en-US", { timeZone: "UTC" }));
  PendingOrdersMounted.value.forEach((order) => {
    const orderDate = new Date(order.OrderDate);
    const diff = (now - orderDate) / 1000;
    order.isOverdue = diff > 900; // 15 minutes
  });
}

// Capatalize the first letter of each word in the title
function capitalizeFirstLetter(string) {
  return string.replace(/(^|\s)\S/g, (match) => match.toUpperCase());
}
</script>

<style scoped>
.draggable-list {
  list-style-type: none;
}

.moving-card {
  background-color: gray;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, background-color 0.2s;
}

/* Flashing effect */
.flash-red {
  animation: flash 1s infinite alternate;
  border-color: red !important;
}

@keyframes flash {
  from {
    background-color: rgba(255, 75, 75, 0.486);
  }
  to {
    background-color: #d2d5da;
  }
}
</style>
<template>
  <Header title="Kitchen" buttons="menu" />
  <div
    id="kitchen"
    class="min-h-screen w-screen bg-white flex flex-col pt-20 justify-center items-center md:items-start md:flex-row"
  >
    <div class="w-full max-w-md text-center px-3">
      <p
        class="mb-2 text-gray-700 text-3xl font-semibold font-sans tracking-wide"
      >
        Pending Orders
      </p>
      <draggable
        tag="ul"
        id="kitchen"
        group="all-orders"
        class="draggable-list"
        ghost-class="moving-card"
        filter=".action-button"
        :list="PendingOrdersMounted"
        :animation="200"
        item-key="OrderID"
        @end="handleDragEnd"
      >
        <template #item="{ element }">
          <div
            :class="[
              'bg-gray-300 m-4 p-2 hover:scale-105 transition-transform transition-colors duration-200 rounded-lg',
              element.isOverdue ? 'flash-red' : '',
            ]"
          >
            <div
              class="bg-gray-100 p-2 rounded shadow flex justify-between items-center mb-2"
            >
              <span>Order #{{ element.OrderID }}</span>
              <Divider layout="vertical" class="mx-2" />
              <span>{{ element.OrderType }}</span>
            </div>
            <div
              v-for="item in parseOrderData(element.OrderData)"
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
              </div>
            </div>
            <p class="text-left mt-2">
              Total Amount:
              <Tag severity="info" rounded icon="pi pi-dollar" class="text-xs">
                {{ element.TotalAmount }}
              </Tag>
              <br />
              Customer ID:
              <Tag severity="info" rounded icon="pi pi-user" class="text-xs">
                {{ element.CustomerID || element.GuestID }}
              </Tag>
              <br />
              Location ID:
              <Tag
                severity="info"
                rounded
                icon="pi pi-map-marker"
                class="text-xs"
              >
                {{ element.LocationID }}
              </Tag>
              <br />
            </p>
            <div class="text-right text-gray-600 text-sm">
              Cooking Time: {{ timeSinceOrder(element.OrderDate) }}
              <FontAwesomeIcon
                icon="fas fa-clock"
                class="text-gray-600 text-sm ml-2"
              />
            </div>
          </div>
        </template>
      </draggable>
    </div>

    <div class="w-full md:w-2/12">
      <Divider layout="vertical" class="!hidden md:!flex"><b>QUEUE</b></Divider>
    </div>

    <div class="w-full max-w-md text-center px-3">
      <p
        class="mb-2 text-gray-700 text-3xl font-semibold font-sans tracking-wide"
      >
        Completed Orders
      </p>
      <draggable
        tag="ul"
        id="done"
        group="all-orders"
        class="draggable-list"
        ghost-class="moving-card"
        filter=".action-button"
        :list="CompletedOrdersMounted"
        :animation="200"
        item-key="OrderID"
        @end="handleDragEnd"
      >
        <template #item="{ element }">
          <div
            class="bg-gray-300 m-4 p-2 hover:scale-105 transition-transform transition-colors duration-200 rounded-lg"
          >
            <div
              class="bg-gray-100 p-2 rounded shadow flex justify-between items-center mb-2"
            >
              <span>Order #{{ element.OrderID }}</span>
              <Divider layout="vertical" class="mx-2" />
              <span>{{ element.OrderType }}</span>
            </div>
            <div
              v-for="item in parseOrderData(element.OrderData)"
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
              </div>
            </div>
            <p class="text-left mt-2">
              Total Amount:
              <Tag
                severity="info"
                rounded
                icon="pi pi-dollar"
                class="text-xs"
                >{{ element.TotalAmount }}</Tag
              ><br />
              Customer ID:
              <Tag severity="info" rounded icon="pi pi-user" class="text-xs">{{
                element.CustomerID || element.GuestID
              }}</Tag
              ><br />
              Location ID:
              <Tag
                severity="info"
                rounded
                icon="pi pi-map-marker"
                class="text-xs"
                >{{ element.LocationID }}</Tag
              ><br />
            </p>
            <div class="text-right text-gray-600 text-sm">
              <FontAwesomeIcon
                icon="fas fa-check"
                class="text-gray-600 text-lg ml-2"
              />
            </div>
          </div>
        </template>
      </draggable>
    </div>
  </div>
</template>
