<script setup>
import InputText from "primevue/inputtext";
import MultiSelect from "primevue/multiselect";
import Checkbox from "primevue/checkbox";
import Button from "primevue/button";
import Dialog from "primevue/dialog";
import Toast from "primevue/toast";
import { ref, reactive } from "vue";

import {
  updateCustomerPreferences,
  updateCustomerDetails,
  checkPassword,
} from "../data/database";
import { useToast } from "primevue/usetoast";

// Define allergy options
const allergyOptions = ref([
  { name: "Dairy", code: "D" },
  { name: "Gluten", code: "G" },
  { name: "Nuts", code: "N" },
  { name: "Shellfish", code: "S" },
  { name: "Soy", code: "Y" },
]);

// toast
const toast = useToast();

const props = defineProps({
  user: Object,
});

// Ensure preferences structure and convert Allergies to an array if needed
const preferences = reactive({
  Allergies: props.user.Preferences?.Allergies
    ? Array.isArray(props.user.Preferences.Allergies)
      ? props.user.Preferences.Allergies // If already an array, just use it
      : props.user.Preferences.Allergies.split(",").map(
          (allergy) =>
            allergyOptions.value.find((option) => option.name === allergy)?.code
        ) // If string, split and match with allergy options
    : [],
  IsVegan: Boolean(props.user.Preferences?.IsVegan === 1),
  IsVegetarian: Boolean(props.user.Preferences?.IsVegetarian === 1),
});

console.log("Preferences:", preferences);

const localUser = reactive(Object.assign({}, props.user));

const saveProfile = () => {
  // Prepare payload for saving, converting Allergies array to string if necessary
  const updatedPreferences = {
    Allergies: preferences.Allergies.map(
      (code) =>
        allergyOptions.value.find((option) => option.code === code)?.name
    ).join(","), // Convert codes back to names and join array to string
    IsVegan: preferences.IsVegan ? 1 : 0,
    IsVegetarian: preferences.IsVegetarian ? 1 : 0,
  };

  console.log("Updated Preferences:", updatedPreferences);

  const updatedUserDetails = {
    Name: localUser.Name,
    Email: localUser.Email,
    Phone: localUser.Phone,
    Address: localUser.Address,
  };

  // If preferences have changed, update them in the database

  updateCustomerPreferences(localUser.CustomerID, updatedPreferences);

  // If user details have changed, update them in the database
  if (
    localUser.Name !== props.user.Name ||
    localUser.Email !== props.user.Email ||
    localUser.Phone !== props.user.Phone ||
    localUser.Address !== props.user.Address ||
    localUser.Password !== props.user.Password
  ) {
    updateCustomerDetails(localUser.CustomerID, updatedUserDetails);
  }

  // Add the preferences to the login object
  localUser.Preferences = updatedPreferences;

  // update and store cookie
  document.cookie = `user=${JSON.stringify(localUser)}`;

  toast.add({
    severity: "success",
    summary: "Success",
    detail: "Profile saved successfully.",
    life: 3000,
  });
};

// Change password dialog
const showChangePasswordDialog = ref(false);

const changePassword = async () => {
  // Get current password, new password, and confirm password
  const currentPassword = document.getElementById("currentPassword").value;
  const newPassword = document.getElementById("newPassword").value;
  const confirmPassword = document.getElementById("confirmPassword").value;

  // Check if new password and confirm password match
  if (newPassword !== confirmPassword) {
    toast.add({
      severity: "error",
      summary: "Error",
      detail: "New password and confirm password do not match.",
      life: 3000,
    });
    return;
  }

  if (!(await checkPassword(props.user.CustomerID, currentPassword))) {
    toast.add({
      severity: "error",
      summary: "Error",
      detail: "Current password is incorrect.",
      life: 3000,
    });
    return;
  }

  toast.add({
    severity: "success",
    summary: "Success",
    detail: "Password changed successfully.",
    life: 3000,
  });

  // Update the user's password in the database
  updateCustomerDetails(props.user.CustomerID, { Password: newPassword });

  // Close the dialog
  showChangePasswordDialog.value = false;
};
</script>

<template>
  <div class="grid grid-cols-2">
    <div class="sm:col-span-2 lg:col-span-1">
      <h5 class="mb-2 text-2xl uppercase font-bold text-black mb-6">
        Profile Information
      </h5>
      <div class="p-fluid p-formgrid p-grid">
        <!-- Profile fields here -->
        <div class="p-field p-col-12 p-md-6">
          <label for="name" class="block mb-1 mt-2">Name</label>
          <InputText id="name" v-model="localUser.Name" class="w-[17rem]" />
        </div>
        <div class="p-field p-col-12 p-md-6">
          <label for="email" class="block mb-1 mt-2">Email</label>
          <InputText
            id="email"
            v-model="localUser.Email"
            v-keyfilter="/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/"
            class="w-[17rem]"
          />
        </div>
        <div class="p-field p-col-12 p-md-6">
          <label for="phone" class="block mb-1 mt-2">Phone</label>
          <InputText id="phone" v-model="localUser.Phone" class="w-[17rem]" />
        </div>
        <div class="p-field p-col-12 p-md-6">
          <label for="address" class="block mb-1 mt-2">Address</label>
          <InputText
            id="address"
            v-model="localUser.Address"
            class="w-[17rem]"
          />
        </div>
        <div class="p-field p-col-12 p-md-6">
          <label for="permissionLevel" class="block mb-1 mt-2"
            >Permission Level</label
          >
          <InputText
            id="permissionLevel"
            v-model="localUser.PermissionLevel"
            :value="localUser.PermissionLevel === 1 ? 'Customer' : 'Staff'"
            readonly
            class="w-[17rem]"
          />
        </div>
      </div>
    </div>
    <div class="col-span-1">
      <h5 class="mb-2 text-2xl uppercase font-bold text-black mb-6">
        Dietary Information
      </h5>
      <div class="p-field p-col-12 p-md-6">
        <label for="allergies" class="block mb-1 mt-2">Allergies</label>
        <MultiSelect
          id="allergies"
          v-model="preferences.Allergies"
          :options="allergyOptions"
          optionLabel="name"
          optionValue="code"
          placeholder="Select allergies"
        />
      </div>
      <div class="p-field p-col-12 p-md-6">
        <label for="diet" class="block mb-1 mt-2">Dietary Preferences</label>
        <div class="p-formgroup-inline">
          <div class="p-field-checkbox">
            <Checkbox id="vegan" v-model="preferences.IsVegan" binary="true" />

            <label class="ml-2" for="vegan">Vegan</label>
          </div>
          <div class="p-field-checkbox">
            <Checkbox
              id="vegetarian"
              v-model="preferences.IsVegetarian"
              binary="true"
            />

            <label class="ml-2" for="vegetarian">Vegetarian</label>
          </div>
        </div>
      </div>
      <!-- Display buttons -->
      <div class="flex flex-col gap-2 mt-4 w-1/2">
        <Button
          severity="primary"
          variant="text"
          raised
          label="Save Profile"
          icon="pi pi-save"
          class="mt-4"
          @click="saveProfile"
          size="small"
        />
        <Button
          severity="contrast"
          variant="text"
          raised
          label="Change Password"
          icon="pi pi-lock"
          class="mt-2"
          @click="showChangePasswordDialog = true"
          size="small"
        />
      </div>
    </div>
  </div>

  <!-- Change password dialog -->
  <Dialog
    v-model="showChangePasswordDialog"
    header="Change Password"
    :visible="showChangePasswordDialog"
    @update:visible="showChangePasswordDialog = $event"
  >
    <div class="p-fluid p-formgrid p-grid">
      <div class="p-field p-col-12 p-md-6">
        <label for="currentPassword" class="block mb-2">Current Password</label>
        <InputText id="currentPassword" type="password" />
      </div>
      <div class="p-field p-col-12 p-md-6">
        <label for="newPassword" class="block mb-2">New Password</label>
        <InputText id="newPassword" type="password" />
      </div>
      <div class="p-field p-col-12 p-md-6">
        <label for="confirmPassword" class="block mb-2">Confirm Password</label>
        <InputText id="confirmPassword" type="password" />
      </div>
      <div class="p-field p-col-12 p-md-6 mt-4">
        <Button
          label="Change Password"
          icon="pi pi-check"
          @click="changePassword"
        />
      </div>
    </div>
  </Dialog>
</template>
