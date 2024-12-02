<script setup>
import Header from "../components/Header.vue";
import Profile from "../components/Profile.vue";
import { getOrdersByCustomer } from "../data/database";
import CompletedOrders from "../components/CompletedOrders.vue";
import { ref, onMounted } from "vue";

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
const completedOrders = ref([]);

onMounted(async () => {
  const orders = await getOrdersByCustomer(user.CustomerID);
  completedOrders.value = orders.filter(
    (order) => order.OrderStatus === "Completed"
  );
});
</script>

<template>
  <div>
    <Header buttons="menu" />

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 m-10">
      <div class="col-span-1 md:col-span-1">
        <div class="w-full p-4 overflow-auto">
          <h5 class="mb-2 text-2xl uppercase font-bold text-black mb-6">
            Order History
          </h5>
          <CompletedOrders :order="completedOrders" />
        </div>
      </div>
      <div class="col-span-1 md:col-span-2 md:ml-8">
        <!-- Allow customer to modify profile information -->
        <div class="w-full p-4 overflow-auto">
          <Profile :user="user" />
        </div>
      </div>
    </div>
  </div>
</template>
