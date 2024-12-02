<template>
  <div class="relative h-full w-64 border-r">
    <!-- Find products search -->
    <div class="p-4">
      <input
        v-model="searchQuery"
        type="text"
        placeholder="Find products..."
        class="w-full p-2 border border-gray-300 rounded focus:outline-none focus:ring focus:border-blue-300"
        @input="onSearchChange"
      />
    </div>
    <!-- Menu title -->
    <div class="p-4">
      <h2 class="text-lg font-bold text-gray-800">Menu</h2>
    </div>
    <nav class="flex flex-col">
      <!-- Go through the categories -->
      <template
        v-for="category in filteredCategories"
        :key="category.CategoryId"
      >
        <Button
          v-if="category.Name !== 'Special Offers'"
          v-slot="slotProps"
          asChild
        >
          <button
            v-bind="slotProps.a11yAttrs"
            @click="handleCategoryClick(category.Path)"
            :class="[
              'w-full text-left p-2 hover:bg-blue-200 focus:outline-none focus:bg-blue-200 text-gray-600 text-lg font-medium pl-4',
              selectedCategory === category.Path
                ? 'bg-blue-200 text-blue-700'
                : '',
            ]"
          >
            <font-awesome-icon
              class="text-lg mr-2"
              :icon="icons[category.Name]"
            />
            {{ category.Name }}
          </button>
        </Button>
      </template>
    </nav>
    <!-- Special Offers -->
    <div class="p-4">
      <Button
        type="button"
        label="Special Offers"
        icon="pi pi-bell"
        :badge="deals.length"
        severity="danger"
        size="small"
        @click="openDeals"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, defineEmits, computed } from "vue";
import { getCategories, getDeals, getMenu } from "../data/database";
import Button from "primevue/button";

const emit = defineEmits(["categorySelected", "searchUpdated"]);

const categories = ref([]);
const selectedCategory = ref("");
const deals = ref([]);
const searchQuery = ref("");

const icons = {
  Pasta: "fas fa-plate-wheat",
  Pizza: "fas fa-pizza-slice",
  Salad: "fas fa-leaf",
  Desserts: "fas fa-ice-cream",
  Drinks: "fas fa-mug-saucer",
};

onMounted(async () => {
  // Load categories and deals
  categories.value = await getCategories();
  if (categories.value.length > 0) {
    selectedCategory.value = categories.value[0].Path;
    emit("categorySelected", selectedCategory.value);
  }

  deals.value = await getDeals();
});

// Define filteredCategories as a function that updates based on the search query
const filteredCategories = computed(() => {
  if (!searchQuery.value) {
    // No search query, return all categories
    // Select Pasta category by default
    handleCategoryClick("pasta");

    return categories.value;
  }

  // Search query entered, filter categories based on items in getMenu
  const filterCategories = async () => {
    const menuItems = await getMenu(); // Fetch all menu items

    console.log(menuItems);

    const matchingItem = menuItems.find((item) =>
      item.Name.toLowerCase().includes(searchQuery.value.toLowerCase())
    );

    console.log(matchingItem);

    const categoryID = matchingItem.CategoryID;

    selectedCategory.value = categories.value.find(
      (category) => category.CategoryId === categoryID
    ).Path;

    handleCategoryClick(selectedCategory.value);


  };

  // Call the async function to return filtered categories
  return filterCategories();
});

function onSearchChange() {
  emit("searchUpdated", searchQuery.value); // Emit the search query to parent
}

function openDeals() {
  selectedCategory.value = "deals";
  emit("categorySelected", "deals");
}

function handleCategoryClick(path) {
  selectedCategory.value = path;
  emit("categorySelected", path);
}
</script>
