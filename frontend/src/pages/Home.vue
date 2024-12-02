<script setup>
// Import database functions
import {
  getCustomer,
  addCustomer,
  loginCustomer,
  resetPassword,
  getCustomerPreferences,
} from "../data/database";
import { ref } from "vue";

import Button from "primevue/button";
import InputText from "primevue/inputtext";
import Dialog from "primevue/dialog";
import { useToast } from "primevue/usetoast";

import WelcomeDialog from "../components/WelcomeDialog.vue";

// State for the welcome dialog
let welcomeDialogVisible = ref(false);

const toast = useToast();

let visible = ref(false);
let visible2 = ref(false);

function generateUniqueId() {
  return "xxxx-xxxx-xxxx-xxxx".replace(/[x]/g, function () {
    return ((Math.random() * 16) | 0).toString(16);
  });
}

// Function to navigate to the next page
function navigate() {
  toast.add({
    severity: "success",
    summary: "Success",
    detail: "Continuing as guest",
    life: 3000,
  });

  // Store guest user in cookie
  document.cookie = `user=${JSON.stringify({
    Name: "Guest",
    PermissionLevel: 0,
    GuestID: generateUniqueId(),
  })}`;

  // Show the welcome dialog
  welcomeDialogVisible.value = true;
}

async function login() {
  const login = await loginCustomer(
    document.getElementById("email1").value,
    document.getElementById("password1").value
  );

  if (!login) {
    toast.add({
      severity: "error",
      summary: "Error",
      detail: "Invalid email or password",
      life: 3000,
    });
    return;
  }

  toast.add({
    severity: "success",
    summary: "Success",
    detail: "Logged in successfully",
    life: 3000,
  });

  // Get the preferences for the customer to add it to the cookie
  const preferences = await getCustomerPreferences(login.CustomerID);

  // Add the preferences to the login object
  login.Preferences = preferences;

  // store cookie
  document.cookie = `user=${JSON.stringify(login)}`;

  // Show the welcome dialog
  welcomeDialogVisible.value = true;
}
// Function to create a new account
async function createAccount() {
  // Close the dialog
  visible.value = false;

  // Get input values
  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;
  const name = document.getElementById("name").value;
  const phone = document.getElementById("phone").value;
  const address = document.getElementById("address").value;

  try {
    // Wait for the result of getCustomer
    const customer = await getCustomer(email);

    // Check if the customer object exists
    if (customer && customer.CustomerID) {
      // Adjusted check for existing customer
      console.log("User already exists");
      toast.add({
        severity: "error",
        summary: "Error",
        detail:
          "Sorry, it looks like an account with this email already exists!",
        life: 5000,
      });
    } else {
      // Add the new customer
      const body = {
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      };
      await addCustomer(body);

      toast.add({
        severity: "success",
        summary: "Success",
        detail:
          "Thanks for joining us! Go ahead and sign in so we can serve you better.",
        life: 5000,
      });
    }
  } catch (error) {
    console.error("Error creating account", error);
  }
}

// Function to handle the forgot password link email
async function forgotPassword() {
  visible2.value = false;

  const email = document.getElementById("email_reset").value;

  if (email == null || email == "") {
    toast.add({
      severity: "error",
      summary: "Error",
      detail: "No email address entered",
      life: 3000,
    });
    return;
  }

  // Check if the email exists in the database
  const customer = await getCustomer(email);

  if (!customer) {
    toast.add({
      severity: "error",
      summary: "Error",
      detail: "No account found with that email address",
      life: 3000,
    });
    return;
  }

  // Send the email to the customer
  await resetPassword(email);
}

// Default value for the polygon fill
let fill = "#ffff";
</script>

<template>
  <!-- 2 column grid layout -->
  <div class="grid grid-cols-1 md:grid-cols-2 h-screen">
    <!-- Left Column: Login Form -->
    <div class="flex items-center justify-center">
      <div class="bg-surface-50 px-6 py-10 md:py-20">
        <div
          class="bg-surface-0 p-6 shadow rounded-border w-full mx-4 md:mx-20"
        >
          <div class="text-center mb-8">
            <img
              src="../assets/logo.png"
              alt="Restaurant"
              class="w-64 mx-auto"
            />

            <div class="text-surface-900 text-3xl font-medium">
              Ready to dine? Sign in!
            </div>
            <span class="text-surface-600 font-medium leading-normal">
              Is this your first visit?
            </span>
            <a
              class="text-primary font-medium no-underline cursor-pointer text-green-600"
              @click="visible = true"
            >
              Create an account
            </a>
          </div>

          <div>
            <label for="email1" class="text-surface-900 font-medium mb-2 block">
              Email
            </label>
            <InputText
              id="email1"
              type="text"
              placeholder="Email address"
              class="w-full mb-4"
            />

            <label
              for="password1"
              class="text-surface-900 font-medium mb-2 block"
            >
              Password
            </label>
            <InputText
              id="password1"
              type="password"
              placeholder="Password"
              class="w-full mb-4"
            />

            <div class="flex items-center justify-between mb-12">
              <a
                class="font-medium no-underline ml-2 text-primary text-right cursor-pointer"
                @click="visible2 = true"
              >
                Forgot password?
              </a>
            </div>

            <div class="flex flex-col md:flex-row justify-between">
              <Button
                label="Sign In"
                icon="pi pi-user"
                class="w-full md:w-1/2 mr-2 p-button-primary mb-2 md:mb-0"
                @click="login"
              />
              <Button
                label="Continue as Guest"
                icon="pi pi-reply"
                class="w-full md:w-1/2 ml-2 p-button-primary"
                @click="navigate"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Dialog for creating an account -->
    <Dialog
      v-model:visible="visible"
      pt:root:class="!border-0 !bg-transparent"
      pt:mask:class="backdrop-blur-sm"
    >
      <template #container="{ closeCallback }">
        <div
          class="flex flex-col px-6 py-6 gap-4 rounded-lg bg-white shadow-md"
        >
          <div class="text-center">
            <img
              src="../assets/logo.png"
              alt="Restaurant"
              class="w-32 mx-auto"
            />
            <h1 class="text-2xl font-semibold text-primary-50">
              Thanks for joining us!
            </h1>
            <p class="text-primary-50">
              We're looking forward to serving you better by saving preferences,
              order history and more!
            </p>
          </div>
          <div class="flex flex-col gap-2 w-full">
            <label for="email" class="text-primary-50 font-semibold"
              >Email</label
            >
            <InputText
              id="email"
              class="!bg-white !border !p-2 !text-primary-900 w-full"
              type="email"
            />
          </div>
          <!-- Password -->
          <div class="flex flex-col gap-2 w-full">
            <label for="password" class="text-primary-50 font-semibold"
              >Password</label
            >
            <InputText
              id="password"
              class="!bg-white/20 !border !p-2 !text-primary-900 w-full"
              type="password"
            />
          </div>
          <div class="flex flex-col gap-2 w-full">
            <label for="name" class="text-primary-50 font-semibold">Name</label>
            <InputText
              id="name"
              class="!bg-white/20 !border !p-2 !text-primary-900 w-full"
            />
          </div>
          <div class="flex flex-col gap-2 w-full">
            <label for="phone" class="text-primary-50 font-semibold"
              >Phone Number</label
            >
            <InputText
              id="phone"
              class="!bg-white/20 !border !p-2 !text-primary-900 w-full"
              type="tel"
            />
          </div>
          <div class="flex flex-col gap-2 w-full">
            <label for="address" class="text-primary-50 font-semibold"
              >Address</label
            >
            <InputText
              id="address"
              class="!bg-white/20 !border !p-2 !text-primary-900 w-full"
            />
          </div>
          <div class="flex items-center gap-2">
            <Button
              label="Sign up Later"
              @click="closeCallback"
              text
              class="!w-full !p-2 !bg-gray-200 !text-gray-800 hover:!bg-gray-300"
            />
            <Button
              label="Register"
              @click="createAccount"
              text
              class="!w-full !p-2 !bg-gray-200 !text-gray-800 hover:!bg-gray-300"
            />
          </div>
        </div>
      </template>
    </Dialog>

    <!-- Password reset -->
    <Dialog
      v-model:visible="visible2"
      pt:root:class="!border-0 !bg-transparent"
      pt:mask:class="backdrop-blur-sm"
    >
      <template #container="{ closeCallback }">
        <div
          class="flex flex-col px-6 py-4 rounded-lg bg-white shadow-md w-[25rem]"
        >
          <h1 class="text-2xl font-semibold text-primary-50">Password Reset</h1>
          <p class="text-primary-50">
            Forgot your password? No worries! Enter your email address and we
            will send you a link to reset your password.
          </p>
          <div class="flex items-center gap-4 mb-4 mt-4">
            <label for="email" class="font-semibold w-24">Your Email</label>
            <InputText id="email_reset" class="flex-auto" autocomplete="off" />
          </div>
          <div class="flex justify-end gap-2">
            <Button
              type="button"
              label="Cancel"
              severity="secondary"
              @click="closeCallback"
            ></Button>
            <Button type="button" label="Save" @click="forgotPassword"></Button>
          </div>
        </div>
      </template>
    </Dialog>

    <!-- Right Column: Angle divider and then image -->
    <!-- Right Column: Angle divider and then image -->
    <div
      class="md:col-span-1 relative flex justify-center items-center h-60 md:h-full"
    >
      <svg
        class="absolute top-0 left-0 z-0 hidden lg:block"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 100 100"
        preserveAspectRatio="none"
      >
        <polygon :fill="fill" points="0,100 40,0 0,0" />
      </svg>
      <img
        src="../assets/plates.jpg"
        alt="Restaurant"
        class="h-full w-full object-cover md:h-full"
      />
    </div>
  </div>

  <!-- Welcome dialog -->
  <WelcomeDialog :visible="welcomeDialogVisible" />
</template>
