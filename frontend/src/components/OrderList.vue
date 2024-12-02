<template>
  <div class="grid grid-cols-1 gap-4 m-10 h-70">
    <div class="col-span-1 w-full p-2 overflow-auto">
      <div v-if="orders.length === 0" class="text-center text-lg text-gray-500">
        {{
          type === "unpaid" ? "No orders requiring payment." : "No paid orders."
        }}
      </div>
      <div v-else>
        <DataView :value="orders" paginator :rows="3">
          <template #list="slotProps">
            <div v-for="(order, index) in slotProps.items" :key="order.OrderID">
              <div
                class="flex flex-col sm:flex-row sm:items-center p-6 gap-4 border-t border-surface-200"
              >
                <div
                  class="flex flex-col md:flex-row justify-between flex-1 gap-6"
                >
                  <VirtualScroller
                    :items="order.OrderData"
                    :itemSize="50"
                    style="width: 300px; height: 100px"
                  >
                    <template #item="{ item, options }">
                      <div
                        :class="[
                          'flex items-center p-2',
                          { 'bg-surface-100': options.odd },
                        ]"
                        style="height: 35px"
                      >
                        {{ item?.title || "No Title" }} -
                        {{ item?.count || 0 }}x
                      </div>
                    </template>
                  </VirtualScroller>
                  <div class="flex flex-col items-end gap-2">
                    <div class="text-right">
                      <strong>Order ID:</strong>
                      <Tag
                        icon="pi pi-tags"
                        :value="order.OrderID"
                        severity="info"
                        style="font-size: 0.75rem"
                      />
                    </div>
                    <div
                      class="text-right font-medium text-surface-500 text-base"
                    >
                      <strong>Paid Date:</strong>
                      <Tag
                        icon="pi pi-calendar"
                        :value="getDate(order)"
                        severity="info"
                        style="font-size: 0.75rem"
                      />
                    </div>
                    <div v-if="type === 'paid'" class="text-right">
                      <strong>Paid:</strong>
                      <Tag
                        :value="order.PaymentMethod.toUpperCase()"
                        severity="secondary"
                        style="font-size: 0.75rem"
                      />
                      <strong> Tip:</strong>
                      <Tag
                        icon="pi pi-dollar"
                        :value="order.Tip"
                        severity="secondary"
                        style="font-size: 0.75rem"
                      />
                    </div>
                    <div
                      v-if="type !== 'paid'"
                      class="flex flex-row-reverse md:flex-row gap-2"
                    >
                      <Button
                        icon="pi pi-credit-card"
                        label="Pay Now"
                        size="small"
                        @click="showDialog(order)"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </DataView>
      </div>
    </div>
  </div>

  <Dialog
    v-model:visible="displayDialog"
    header="Payment"
    modal
    closable
    :style="{ width: '35vw' }"
  >
    <div class="flex flex-col gap-4">
      <div class="flex flex-row justify-between items-center">
        <span class="text-lg">Order ID:</span>
        <Tag
          icon="pi pi-tags"
          :value="selectedOrder.OrderID"
          severity="info"
          style="font-size: 0.75rem"
        />
      </div>
      <div class="flex flex-row justify-between items-center">
        <span class="text-lg">Order Date:</span>
        <Tag
          icon="pi pi-calendar"
          :value="new Date(selectedOrder.OrderDate).toLocaleDateString()"
          severity="info"
          style="font-size: 0.75rem"
        />
      </div>
      <div class="flex flex-row justify-between items-center">
        <span class="text-lg">Total Amount:</span>
        <Tag
          icon="pi pi-dollar"
          :value="selectedOrder.TotalAmount"
          severity="info"
          style="font-size: 0.75rem"
        />
      </div>
      <div class="flex flex-row justify-between items-center">
        <span class="text-lg">Payment Method:</span>
        <SelectButton
          v-model="selectedPaymentMethod"
          :options="paymentMethods"
          optionLabel="name"
          optionValue="value"
        />
      </div>
      <div class="flex flex-row justify-between items-center">
        <span class="text-lg">Tip %:</span>
        <InputNumber
          v-model="tipPercentage"
          showButtons
          suffix="%"
          :min="0"
          :step="5"
        />
      </div>
      <div class="flex flex-row-reverse gap-4">
        <Button
          label="Pay"
          icon="pi pi-credit-card"
          @click="payOrder"
          class="w-1/4"
        />
        <Button
          label="Cancel"
          icon="pi pi-times"
          @click="displayDialog = false"
          class="w-1/4"
        />
      </div>
    </div>
  </Dialog>
</template>

<script setup>
import { ref } from "vue";
import DataView from "primevue/dataview";
import Button from "primevue/button";
import VirtualScroller from "primevue/virtualscroller";
import Dialog from "primevue/dialog";
import SelectButton from "primevue/selectbutton";
import InputNumber from "primevue/inputnumber";
import Tag from "primevue/tag";
import { useToast } from "primevue/usetoast";
import { addPayment } from "../data/database";

const displayDialog = ref(false);
const selectedOrder = ref(null);
const selectedPaymentMethod = ref(null);
const tipPercentage = ref(0);
const toast = useToast();

const paymentMethods = [
  { name: "Credit Card", value: "credit_card" },
  { name: "Debit Card", value: "debit_card" },
  { name: "Cash", value: "cash" },
];

const props = defineProps({
  orders: Array,
  type: String,
});

const getDate = (order) => {
  return props.type === "paid"
    ? new Date(order.PaymentDate).toLocaleDateString()
    : new Date(order.OrderDate).toLocaleDateString();
};

const showDialog = (order) => {
  selectedOrder.value = order;
  displayDialog.value = true;
};

const payOrder = async () => {
  await addPayment({
    PaymentDate: new Date().toISOString().split("T")[0] + " 00:00:00",
    Amount: selectedOrder.value.TotalAmount,
    Tip: (selectedOrder.value.TotalAmount * tipPercentage.value) / 100,
    PaymentMethod: selectedPaymentMethod.value,
    OrderID: selectedOrder.value.OrderID,
  });
  displayDialog.value = false;
  location.reload();
  toast.add({
    severity: "success",
    summary: "Payment Successful",
    detail: "Your payment has been processed successfully.",
  });
};
</script>
