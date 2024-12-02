<template>
    <Menubar :model="items">
      <template #start>
        <!-- Logo -->
        <img
          src="../assets/logo.png"
          alt="Restaurant"
          class="w-24 sm:w-28 md:w-36"
        />
      </template>
      <template #item="{ item, props }">
        <router-link
          v-if="item.route"
          v-slot="{ href, navigate }"
          :to="item.route"
          custom
        >
          <a v-ripple :href="href" v-bind="props.action" @click="navigate">
            <span :class="item.icon" />
            <span>{{ item.label }}</span>
          </a>
        </router-link>
      </template>
      <template #end>
        <div class="flex items-center gap-2">
          <!-- Greet the user -->
          <div class="text-right mr-6">
            <p class="text-gray-800 text-md">{{ greeting }}</p>
            <p class="text-gray-600 text-sm">
              {{ locationDetails.location }} -
              {{ locationDetails.diningOption }}
            </p>
          </div>

          <Button
            v-if="user"
            label="Sign Out"
            icon="pi pi-sign-out"
            @click="signOut"
            class="p-button-danger p-button-outlined p-button-rounded p-button-sm"
          />
        </div>
      </template>
    </Menubar>
</template>

<script setup>
import { defineProps, ref } from "vue";
import { useRouter } from "vue-router";

import Menubar from "primevue/menubar";
import Badge from "primevue/badge";
import Button from "primevue/button";
import { useToast } from "primevue/usetoast";

import { removeGuestOrders } from "../data/database";

const toast = useToast();

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

// Greet the user
const greeting = user ? `Hello, ${user.Name}` : "Hello";

const locationDetails = ref({
  location: localStorage.getItem("location")
    ? localStorage.getItem("location").split(",")[1].trim()
    : "Unknown Location",
  diningOption: localStorage.getItem("diningOption") || "Unknown Dining Option",
});

const items = [
  {
    label: "Menu",
    icon: "pi pi-fw pi-book",
    route: "/menu",
  },
  {
    label: "Orders",
    icon: "pi pi-fw pi-table",
    route: "/orders",
  },
  {
    label: "Pay",
    icon: "pi pi-fw pi-credit-card",
    route: "/pay",
  },
];

// Add profile if PermisioLevel is > 0
if (user && user.PermissionLevel > 0) {
  items.push({
    label: "Profile",
    icon: "pi pi-fw pi-user",
    route: "/profile",
  });
}

// Add Kitchen tab for users with PermissionLevel 2
if (user && user.PermissionLevel === 2) {
  items.push({
    label: "Kitchen",
    icon: "pi pi-fw pi-box",
    route: "/kitchen",
  });
  items.push({
    label: "Management",
    icon: "pi pi-fw pi-cog",
    route: "/management",
  });
  items.push({
    label: "Reservations",
    icon: "pi pi-fw pi-phone",
    route: "/reservations",
  });
}

const props = defineProps({
  title: {
    type: String,
    required: true,
  },
  buttons: {
    type: String,
    required: true,
  },
});

const clockTime = ref("");

// Time Formatting Function
const formatTime = (time) => {
  const options = { timeStyle: "short", hour12: true };
  return new Intl.DateTimeFormat("default", options)
    .format(time)
    .replace("a.m.", "AM")
    .replace("p.m.", "PM");
};

// Initialize Time and Update Every Second
const now = new Date();
let currentTime = now;
clockTime.value = formatTime(currentTime);

setInterval(() => {
  currentTime.setSeconds(currentTime.getSeconds() + 1);
  clockTime.value = formatTime(currentTime);
}, 1000);

// Router Navigation for Mobile Dropdown
const router = useRouter();
const navigateTo = (event) => {
  const path = event.target.value;
  if (path) {
    router.push(path);
  }
};

// Sign Out Function
const signOut = () => {
  // is there an active order?
  if (localStorage.getItem("order")) {
    // warn the user
    toast.add({
      severity: "warn",
      summary: "Oops!",
      detail:
        "I'm sorry, you have an active order. Please call your server before signing out.",
      life: 5000,
    });
    if (
      !confirm("You have an active order. Are you sure you want to sign out?")
    ) {
      return;
    }
  }

  // if user is a guest, delete all associated orders
  if (user && user.GuestID) {
    removeGuestOrders(user.GuestID);
  }

  // remove user cookie
  document.cookie = "user=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";

  // go to login page
  router.push("/");
};
</script>
