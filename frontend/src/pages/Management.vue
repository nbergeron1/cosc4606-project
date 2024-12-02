<script setup>
import Header from "../components/Header.vue";
import Tabs from "primevue/tabs";
import TabList from "primevue/tablist";
import Tab from "primevue/tab";
import TabPanel from "primevue/tabpanel";

import ButtonGroup from "primevue/buttongroup";
import Button from "primevue/button";
import Dialog from "primevue/dialog";
import InputText from "primevue/inputtext";
import Paginator from "primevue/paginator";

import { useToast } from "primevue/usetoast";

import { ref, onMounted, computed } from "vue";
import {
  getCustomers,
  updateCustomerDetails,
  deleteCustomer,
  getLocations,
  updateLocation,
  addLocation,
  deleteLocation,
  getDeals,
  addDeal,
  updateDeal,
  deleteDeal,
} from "../data/database";

const customers = ref([]);
const locations = ref([]);
const deals = ref([]);
const displayDealDialog = ref(false);
const selectedDeal = ref(null);
const displayEditDialog = ref(false);
const selectedCustomer = ref(null);
const displayLocationDialog = ref(false);
const selectedLocation = ref(null);
const toast = useToast();

const rowsPerPage = 9;
const currentCustomerPage = ref(0);
const currentLocationPage = ref(0);
const currentDealPage = ref(0);

onMounted(async () => {
  locations.value = await getLocations();
  customers.value = await getCustomers();
  deals.value = await getDeals();
});

const onCustomerPageChange = (event) => {
  currentCustomerPage.value = event.page;
};

const onDealsPageChange = (event) => {
  currentDealPage.value = event.page;
};

const onLocationsPageChange = (event) => {
  currentLocationPage.value = event.page;
};

const paginatedCustomers = computed(() => {
  return customers.value.slice(
    currentCustomerPage.value * rowsPerPage,
    (currentCustomerPage.value + 1) * rowsPerPage
  );
});

const paginatedLocations = computed(() => {
  return locations.value.slice(
    currentLocationPage.value * rowsPerPage,
    (currentLocationPage.value + 1) * rowsPerPage
  );
});

const paginatedDeals = computed(() => {
  return deals.value.slice(
    currentDealPage.value * rowsPerPage,
    (currentDealPage.value + 1) * rowsPerPage
  );
});

// Function to open the edit dialog with selected customer's data
const editCustomer = (customer) => {
  selectedCustomer.value = {
    CustomerID: customer.CustomerID,
    Name: customer.Name,
    Email: customer.Email,
    Phone: customer.Phone,
    Address: customer.Address,
  };
  displayEditDialog.value = true;
};

// Function to save the updated customer details
const saveCustomer = async () => {
  await updateCustomerDetails(
    selectedCustomer.value.CustomerID,
    selectedCustomer.value
  );
  const updatedCustomers = await getCustomers();
  customers.value = updatedCustomers; // Refresh customer list
  displayEditDialog.value = false; // Close dialog
};

const removeCustomer = async (customer) => {
  if (confirm(`Are you sure you want to delete ${customer.Name}?`)) {
    await deleteCustomer(customer.CustomerID);
    const updatedCustomers = await getCustomers();
    customers.value = updatedCustomers; // Refresh customer list
  }
};

// Location Functions
const editLocation = (location) => {
  selectedLocation.value = { ...location };
  displayLocationDialog.value = true;
};

const addNewLocation = () => {
  selectedLocation.value = {
    Address: "",
    City: "",
    Province: "",
    ZipCode: "",
    Phone: "",
  };
  displayLocationDialog.value = true;
};

const saveLocation = async () => {
  if (selectedLocation.value.LocationID) {
    await updateLocation(
      selectedLocation.value.LocationID,
      selectedLocation.value
    );
  } else {
    await addLocation(selectedLocation.value);
  }
  locations.value = await getLocations(); // Refresh location list
  displayLocationDialog.value = false;
};

const removeLocation = async (location) => {
  if (confirm(`Are you sure you want to delete ${location.Address}?`)) {
    await deleteLocation(location.LocationID);
    locations.value = await getLocations(); // Refresh location list
  }
};

// Deal Functions
const editDeal = (deal) => {
  selectedDeal.value = { ...deal };
  displayDealDialog.value = true;
};

const addNewDeal = () => {
  selectedDeal.value = {
    DealID: null,
    Title: "",
    Description: "",
    Discount: 0,
  };
  displayDealDialog.value = true;
};

const saveDeal = async () => {
  if (selectedDeal.value.DealID) {
    await updateDeal(selectedDeal.value.DealID, selectedDeal.value);
  } else {
    await addDeal(selectedDeal.value);
  }
  deals.value = await getDeals(); // Refresh deal list
  displayDealDialog.value = false;
};

const removeDeal = async (deal) => {
  if (confirm(`Are you sure you want to delete ${deal.Name}?`)) {
    await deleteDeal(deal.DealID);
    deals.value = await getDeals(); // Refresh deal list
  }
};
</script>

<template>
  <Header />

  <div class="grid grid-cols-1 gap-2 m-10">
    <Tabs value="0">
      <TabList>
        <Tab value="0" class="text-lg">Customers</Tab>
        <Tab value="1" class="text-lg">Locations</Tab>
        <Tab value="2" class="text-lg">Promotions</Tab>
      </TabList>
      <TabPanel value="0">
        <div class="w-full overflow-auto">
          <table class="min-w-full table-auto">
            <thead>
              <tr>
                <th class="text-left px-4 py-2">Name</th>
                <th class="text-left px-4 py-2">Email</th>
                <th class="text-left px-4 py-2">Phone Number</th>
                <th class="text-left px-4 py-2">Address</th>
                <th class="text-left px-4 py-2">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="customer in paginatedCustomers"
                :key="customer.id"
                class="border-t"
              >
                <td class="px-4 py-2">{{ customer.Name }}</td>
                <td class="px-4 py-2">{{ customer.Email }}</td>
                <td class="px-4 py-2">{{ customer.Phone }}</td>
                <td class="px-4 py-2">{{ customer.Address }}</td>
                <td class="px-4 py-2">
                  <ButtonGroup>
                    <Button
                      icon="pi pi-pencil"
                      size="small"
                      class="p-button-contrast"
                      @click="editCustomer(customer)"
                    />
                    <Button
                      icon="pi pi-trash"
                      size="small"
                      class="p-button-contrast"
                      @click="removeCustomer(customer)"
                    />
                  </ButtonGroup>
                </td>
              </tr>
            </tbody>
          </table>
          <Paginator
            :rows="rowsPerPage"
            :totalRecords="customers.length"
            :first="currentCustomerPage * rowsPerPage"
            @page="onCustomerPageChange"
          ></Paginator>
        </div>
      </TabPanel>
      <TabPanel value="1">
        <div class="w-full overflow-auto">
          <div class="flex justify-end mb-4 mr-[7rem]">
            <Button
              label="New Location"
              icon="pi pi-plus"
              @click="addNewLocation"
            />
          </div>
          <table class="min-w-full table-auto">
            <thead>
              <tr>
                <th class="text-left px-4 py-2">Address</th>
                <th class="text-left px-4 py-2">City</th>
                <th class="text-left px-4 py-2">Province</th>
                <th class="text-left px-4 py-2">Postal Code</th>
                <th class="text-left px-4 py-2">Phone</th>
                <th class="text-left px-4 py-2">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="location in paginatedLocations"
                :key="location.id"
                class="border-t"
              >
                <td class="px-4 py-2">{{ location.Address }}</td>
                <td class="px-4 py-2">{{ location.City }}</td>
                <td class="px-4 py-2">{{ location.Province }}</td>
                <td class="px-4 py-2">{{ location.ZipCode }}</td>
                <td class="px-4 py-2">{{ location.Phone }}</td>
                <td class="px-4 py-2">
                  <ButtonGroup>
                    <Button
                      icon="pi pi-pencil"
                      size="small"
                      class="p-button-contrast"
                      @click="editLocation(location)"
                    />
                    <Button
                      icon="pi pi-trash"
                      size="small"
                      class="p-button-contrast"
                      @click="removeLocation(location)"
                    />
                  </ButtonGroup>
                </td>
              </tr>
            </tbody>
          </table>
          <Paginator
            :rows="rowsPerPage"
            :totalRecords="locations.length"
            :first="currentLocationPage * rowsPerPage"
            @page="onLocationsPageChange"
          ></Paginator>
        </div>
      </TabPanel>
      <TabPanel value="2">
        <div class="w-full overflow-auto">
          <div class="flex justify-end mb-4 mr-[6rem]">
            <Button
              label="New Promotion"
              icon="pi pi-plus"
              @click="addNewDeal"
            />
          </div>
          <table class="min-w-full table-auto">
            <thead>
              <tr>
                <th class="text-left px-4 py-2">Name</th>
                <th class="text-left px-4 py-2">Description</th>
                <th class="text-left px-4 py-2">Discount</th>
                <th class="text-left px-4 py-2">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="deal in paginatedDeals" :key="deal.id" class="border-t">
                <td class="px-4 py-2">{{ deal.Title }}</td>
                <td class="px-4 py-2">{{ deal.Description }}</td>
                <td class="px-4 py-2">{{ deal.Discount * 100 }}%</td>
                <td class="px-4 py-2">
                  <ButtonGroup>
                    <Button
                      icon="pi pi-pencil"
                      size="small"
                      class="p-button-contrast"
                      @click="editDeal(deal)"
                    />
                    <Button
                      icon="pi pi-trash"
                      size="small"
                      class="p-button-contrast"
                      @click="removeDeal(deal)"
                    />
                  </ButtonGroup>
                </td>
              </tr>
            </tbody>
          </table>
          <Paginator
            :rows="rowsPerPage"
            :totalRecords="deals.length"
            :first="currentDealPage * rowsPerPage"
            @page="onDealsPageChange"
          ></Paginator>
        </div>
      </TabPanel>
    </Tabs>
  </div>

  <!-- Edit Customer Dialog -->
  <Dialog
    v-model:visible="displayEditDialog"
    header="Edit Customer"
    :modal="true"
    :closable="true"
  >
    <div class="flex flex-col gap-4">
      <div class="flex flex-row gap-4">
        <span class="text-lg">Name:</span>
        <InputText v-model="selectedCustomer.Name" />
      </div>
      <div class="flex flex-row gap-4">
        <span class="text-lg">Email:</span>
        <InputText v-model="selectedCustomer.Email" />
      </div>
      <div class="flex flex-row gap-4">
        <span class="text-lg">Phone Number:</span>
        <InputText v-model="selectedCustomer.Phone" />
      </div>
      <div class="flex flex-row gap-4">
        <span class="text-lg">Address:</span>
        <InputText v-model="selectedCustomer.Address" />
      </div>
      <div class="flex flex-row-reverse gap-4">
        <Button label="Save" icon="pi pi-check" @click="saveCustomer" />
        <Button
          label="Cancel"
          icon="pi pi-times"
          @click="displayEditDialog = false"
        />
      </div>
    </div>
  </Dialog>

  <!-- Location Dialog -->
  <Dialog
    v-model:visible="displayLocationDialog"
    header="Manage Location"
    :modal="true"
    :closable="true"
  >
    <div class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label for="address" class="text-lg font-semibold">Address:</label>
        <InputText id="address" v-model="selectedLocation.Address" />
      </div>
      <div class="flex flex-col gap-2">
        <label for="city" class="text-lg font-semibold">City:</label>
        <InputText id="city" v-model="selectedLocation.City" />
      </div>
      <div class="flex flex-col gap-2">
        <label for="province" class="text-lg font-semibold">Province:</label>
        <InputText id="province" v-model="selectedLocation.Province" />
      </div>
      <div class="flex flex-col gap-2">
        <label for="postal-code" class="text-lg font-semibold"
          >Postal Code:</label
        >
        <InputText id="postal-code" v-model="selectedLocation.ZipCode" />
      </div>
      <div class="flex flex-col gap-2">
        <label for="phone" class="text-lg font-semibold">Phone:</label>
        <InputText id="phone" v-model="selectedLocation.Phone" />
      </div>
      <div class="flex flex-row-reverse gap-4 mt-4">
        <Button label="Save" icon="pi pi-check" @click="saveLocation" />
        <Button
          label="Cancel"
          icon="pi pi-times"
          @click="displayLocationDialog = false"
        />
      </div>
    </div>
  </Dialog>

  <!-- Deal Dialog -->
  <Dialog
    v-model:visible="displayDealDialog"
    header="Manage Promotion"
    :modal="true"
    :closable="true"
  >
    <div class="flex flex-col gap-4">
      <div class="flex flex-col gap-2">
        <label for="name" class="text-lg font-semibold">Name:</label>
        <InputText id="name" v-model="selectedDeal.Title" />
      </div>
      <div class="flex flex-col gap-2">
        <label for="description" class="text-lg font-semibold"
          >Description:</label
        >
        <InputText id="description" v-model="selectedDeal.Description" />
      </div>
      <div class="flex flex-col gap-2">
        <label for="discount" class="text-lg font-semibold">Discount:</label>
        <InputText id="discount" v-model="selectedDeal.Discount" />
      </div>
      <div class="flex flex-row-reverse gap-4 mt-4">
        <Button label="Save" icon="pi pi-check" @click="saveDeal" />
        <Button
          label="Cancel"
          icon="pi pi-times"
          @click="displayDealDialog = false"
        />
      </div>
    </div>
  </Dialog>
</template>
