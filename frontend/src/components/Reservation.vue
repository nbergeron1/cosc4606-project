<template>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 overflow-auto" style="max-height: 70vh;">
        <Card
            v-for="reservation in reservations"
            :key="reservation.id"
            class="shadow-2"
            style="width: 20rem"
        >
            <template #title>
                <h5 class="ml-2">Reservation #{{ reservation.ReservationID }}</h5>
            </template>
            <template #content>
                <div class="p-2">
                    <p><strong>Date:</strong> {{ new Date(reservation.ReservationDate).toLocaleDateString() }}</p>
                    <p><strong>Time:</strong> {{ new Date('1999-01-01T' + reservation.ReservationTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }}</p>
                    <p><strong>Guests:</strong> {{ reservation.NumberOfGuests }}</p>
                    <p><strong>Phone:</strong> {{ reservation.Phone }}</p>
                </div>

                <!-- Notes -->
                <div class="m-1" style="height: 3rem; overflow-y: auto;">
                    <p>{{ reservation.Notes }}</p>
                </div>

            </template>
            <template #footer>
                <div class="ml-1">
                    <Button label="Cancel" icon="pi pi-times" class="p-button-danger p-button-sm" @click="cancelReservation(reservation)"  />
                </div>
            </template>
        </Card>
    </div>
</template>

<script setup>
import { defineProps } from "vue";
import Card from "primevue/card";
import Button from "primevue/button";
import Tag from "primevue/tag";
import { deleteReservation } from "../data/database";

const props = defineProps({
  reservations: {
    type: Array,
    required: true,
  },
});

const cancelReservation = async (reservation) => {
  const confirmed = confirm("Are you sure you want to cancel this reservation?");
  if (confirmed) {
    await deleteReservation(reservation.ReservationID);
    location.reload();
  }
};


</script>
