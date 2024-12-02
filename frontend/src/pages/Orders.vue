<script setup>
import Header from '../components/Header.vue';
import PendingOrders from '../components/PendingOrders.vue';
import PreviousOrders from '../components/PreviousOrders.vue';
import CompletedOrders from '../components/CompletedOrders.vue';
import { onMounted, ref, onUnmounted } from 'vue';
import { getOrders, updateOrderStatus, addOrder } from '../data/database';

const getLoggedInUserFromCookie = () => {
    // Return null if no user cookie is found
    if (!document.cookie.split(';').some((item) => item.trim().startsWith('user='))) {
        return null;
    }
    const cookie = document.cookie
        .split('; ')
        .find(row => row.startsWith('user='))
        .split('=')[1];
    console.log(cookie ? JSON.parse(decodeURIComponent(cookie)) : null);
    return cookie ? JSON.parse(decodeURIComponent(cookie)) : null;
};

const user = getLoggedInUserFromCookie();

const completedOrders = ref([]);
const activeOrders = ref([]);

const fetchOrders = async () => {

    const currentDate = new Date().toLocaleDateString('en-CA', { timeZone: 'UTC' });
    console.log(currentDate);
    const orders = await getOrders(user.CustomerID || user.GuestID, currentDate);

    console.log('Orders:', orders);

    // Separate the orders into active and completed orders
    completedOrders.value = [];
    activeOrders.value = [];
    orders.forEach(order => {
        if (order.OrderStatus === 'Completed') {
            completedOrders.value.push(order);
        } else {
            activeOrders.value.push(order);
        }
    });
};

onMounted(() => {
    fetchOrders();
    const interval = setInterval(fetchOrders, 30000); // Refresh every 30 seconds

    onUnmounted(() => {
        clearInterval(interval);
    });
});

// get the order from local storage
const order = JSON.parse(localStorage.getItem('order') || '[]');

// capatalize first letter of each word
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

// modify the order to capitalize the first letter of each word
for (let i = 0; i < order.length; i++) {
    order[i].title = capitalizeFirstLetter(order[i].title);
}

//const previousOrder = ref(JSON.parse(localStorage.getItem('activeOrders') || '[]'));
//const completedOrder = ref(JSON.parse(localStorage.getItem('completedOrders') || '[]'));

// Function to update the previousOrder ref when an order is placed
function updateOrders() {
    console.log('Updating orders')
    // Refresh the data from local storage or use any other logic
    //previousOrder.value = JSON.parse(localStorage.getItem('activeOrders') || '[]');
    //completedOrder.value = JSON.parse(localStorage.getItem('completedOrders') || '[]');
}

</script>

<template>
    <div>
        <Header title="Orders" buttons="menu" />

        <div class="grid grid-cols-3">

            <!-- Make 3 columns that fit the whole tablet -->

            <!-- Column 1: Order summary -->
            <div class="col-span-1">
                <div class="card_orders">
                    <div class="w-full p-4 overflow-auto">
                        <!-- DIsplay localstorage order array -->
                        <h5 class="mb-2 text-2xl uppercase font-bold text-black mb-6">Completed</h5>
                        <CompletedOrders :order="completedOrders" />
                    </div>
                </div>
            </div>

            <!-- Column 2: Order items -->
            <div class="col-span-1 border-r-2 border-l-2">
                <div class="card_orders">
                    <div class="w-full p-4 overflow-auto">
                        <!-- DIsplay localstorage order array -->
                        <h5 class="mb-4 text-2xl uppercase font-bold text-black ">In Progress</h5>
                        <PreviousOrders :order="activeOrders" @movedToComplete="updateOrders" />
                    </div>
                </div>
            </div>

            <!-- Column 3: Current Order -->
            <div class="col-span-1">
                <div class="card_orders">
                    <div class="w-full p-4">
                        <!-- DIsplay localstorage order array -->
                        <h5 class="mb-2 text-2xl uppercase font-bold text-black ">Pending</h5>
                        <div class="border-2 rounded-xl mt-6 p-4">
                            <!-- DIsplau content from order -->
                            <p class="text-xl text-black font-semibold mb-4">Current Order</p>
                            <PendingOrders :order="order" @orderPlaced="updateOrders" />
                        </div>
                    </div>
                </div>
            </div>

        </div>


    </div>
</template>
