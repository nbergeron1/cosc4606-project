<template>
  <Header />

  <!-- Display a list of all orders from orders that do not have a matching row in payment with OrderID -->
  <div class="grid grid-cols-2 gap-2 m-10 overflow-hidden">
    <div class="col-span-2 md:col-span-1">
      <Tabs value="0">
      <TabList>
        <Tab value="0" class="text-lg">Orders to be Paid</Tab>
        <Tab value="1" class="text-lg">Previously Paid Orders</Tab>
      </TabList>
      <TabPanel value="0">
        <div class="w-full overflow-auto">
        <OrderList :orders="orders" type="unpaid" />
        </div>
      </TabPanel>
      <TabPanel value="1">
        <div class="w-full overflow-auto">
        <OrderList :orders="paidOrders" type="paid" />
        </div>
      </TabPanel>
      </Tabs>
    </div>
    <div class="col-span-1 flex justify-center items-center hidden md:flex">
      <img src="../assets/3598148-middle.png" alt="Image Description" class="w-[32rem] h-[32rem] object-cover" />
    </div>
  </div>
</template>

<script setup>
import Header from "../components/Header.vue";
import OrderList from "../components/OrderList.vue";

import Tabs from "primevue/tabs";
import TabList from "primevue/tablist";
import Tab from "primevue/tab";
import TabPanel from "primevue/tabpanel";

import { getOrdersNoPayment, getOrdersAlreadyPaid } from "../data/database";
import { ref, onMounted, watchEffect  } from "vue";

const orders = ref([]);
const paidOrders = ref([]);

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

onMounted(async () => {
  const cusId = user ? user.CustomerID : null || user ? user.GuestID : null;
  console.log(cusId)
  const rawOrders = await getOrdersNoPayment(cusId);
  const rawPaidOrders = await getOrdersAlreadyPaid(cusId);

  orders.value = rawOrders.map((order) => ({
    ...order,
    OrderData: JSON.parse(order.OrderData),
  }));

  paidOrders.value = rawPaidOrders.map((order) => ({
    ...order,
    OrderData: JSON.parse(order.OrderData),
  }));
});

watchEffect(() => {
  orders.value = orders.value.map((order) => ({
    ...order,
    OrderData: Array.isArray(order.OrderData) ? order.OrderData : JSON.parse(order.OrderData),
  }));

  paidOrders.value = paidOrders.value.map((order) => ({
    ...order,
    OrderData: Array.isArray(order.OrderData) ? order.OrderData : JSON.parse(order.OrderData),
  }));
});

</script>
