<script setup>
import Header from "../components/Header.vue";
import Reservation from "../components/Reservation.vue";
import {
  getReservations,
  getLocations,
  addReservation,
} from "../data/database";
import { ref, onMounted } from "vue";

import InputText from "primevue/inputtext";
import Button from "primevue/button";
import Calendar from "primevue/calendar";
import Select from "primevue/select";
import InputNumber from "primevue/inputnumber";
import Dialog from "primevue/dialog";

const reservations = ref([]);
const locations = ref([]);
const locationOptions = ref([]);
const dialogVisible = ref(false);

// Form fields for new reservation
const phone = ref("");
const date = ref(null);
const time = ref("");
const location = ref(null);
const guests = ref("");
const notes = ref("");

onMounted(async () => {
  reservations.value = await getReservations();
  console.log(reservations.value);
  locations.value = await getLocations();
  if (locations.value.length > 0) {
    location.value = locations.value[0];
  }
  // format the location options
  locationOptions.value = locations.value.map((location) => ({
    name: location.Address,
    code: location.LocationID,
  }));
});

const createReservation = () => {
  // Logic to handle reservation creation
  console.log({
    phone: phone.value,
    date: date.value,
    time: time.value,
    location: location.value,
    guests: guests.value,
    notes: notes.value,
  });

  // Add reservation to database
  addReservation({
    Phone: phone.value,
    ReservationDate: date.value.toISOString().split('T')[0],
    ReservationTime: time.value.toTimeString().split(' ')[0],
    LocationID: location.value.code,
    NumberOfGuests: guests.value,
    Notes: notes.value,
  });

  // Reset form fields and close dialog
  date.value = null;
  time.value = "";
  location.value = null;
  guests.value = "";
  phone.value = "";
  notes.value = "";
  dialogVisible.value = false;
};
</script>

<template>
  <div>
    <Header buttons="menu" />
    <!-- Action Button -->
    <div class="flex p-4 ml-5 mt-4">
      <Button
        label="Add Reservation"
        icon="pi pi-plus"
        class="p-button-success"
        @click="dialogVisible = true"
      />
    </div>
    <!-- Reservations Grid -->
    <div class="p-4">
      <Reservation :reservations="reservations" />
    </div>
    <!-- Dialog for New Reservation -->
    <Dialog
      header="Create Reservation"
      v-model:visible="dialogVisible"
      modal
      class="w-34"
    >
      <form class="p-fluid" @submit.prevent="createReservation">
        <div class="p-field p-grid">
          <label for="location" class="p-col-12 p-md-2 p-mb-2 p-md-mb-0"
            >Location</label
          >
          <div class="p-col-12 p-md-10">
            <Select
              v-model="location"
              :options="locationOptions"
              optionLabel="name"
              placeholder="Please select your location..."
              class="w-full"
            />
          </div>
        </div>
        <div class="p-field p-grid">
          <label for="date" class="p-col-12 p-md-2 p-mb-2 p-md-mb-0"
            >Date</label
          >
          <div class="p-col-12 p-md-10">
            <Calendar id="date" v-model="date" class="w-full" />
          </div>
        </div>
        <div class="p-field p-grid">
          <label for="time" class="p-col-12 p-md-2 p-mb-2 p-md-mb-0"
            >Time</label
          >
          <div class="p-col-12 p-md-10">
            <Calendar id="time" v-model="time" timeOnly hourFormat="24" class="w-full" />
          </div>
        </div>
        <div class="p-field p-grid">
          <label for="guests" class="p-col-12 p-md-2 p-mb-2 p-md-mb-0"
            >Guests</label
          >
          <div class="p-col-12 p-md-10">
            <InputNumber
              v-model="guests"
              inputId="horizontal-buttons"
              showButtons
              buttonLayout="horizontal"
              :step="1"
              mode="decimal"
              fluid
            >
              <template #incrementbuttonicon>
                <span class="pi pi-plus" />
              </template>
              <template #decrementbuttonicon>
                <span class="pi pi-minus" />
              </template>
            </InputNumber>
          </div>
        </div>
        <div class="p-field p-grid">
          <label for="phone" class="p-col-12 p-md-2 p-mb-2 p-md-mb-0"
            >Phone</label
          >
          <div class="p-col-12 p-md-10">
            <InputText id="phone" v-model="phone" class="w-full" />
          </div>
        </div>
        <div class="p-field p-grid">
          <label for="notes" class="p-col-12 p-md-2 p-mb-2 p-md-mb-0"
            >Notes</label
          >
          <div class="p-col-12 p-md-10">
            <InputText id="notes" v-model="notes" class="w-full" />
          </div>
        </div>
        <div class="flex justify-end mt-4">
          <Button
            label="Cancel"
            class="p-button-text mr-2"
            @click="dialogVisible = false"
          />
          <Button label="Create" class="p-button-success" type="submit" />
        </div>
      </form>
    </Dialog>
  </div>
</template>
