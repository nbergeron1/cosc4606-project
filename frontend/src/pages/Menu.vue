<template>
  <div>
    <Header title="Menu - Dinner" buttons="menu" />

    <div class="grid grid-cols-[max-content_1fr] grid-rows-[max-content_1fr]">
      <!-- Sidenav -->
      <Sidenav
        class="row-span-2"
        @categorySelected="handleCategorySelected"
        @searchUpdated="handleSearchUpdated"
      />

      <!-- Filter bar -->
      <div class="col-start-2" v-if="section !== 'deals'">
        <!-- filter buttons -->
        <div class="flex justify-center">
          <template v-for="filter in filters">
            <button
              :class="{
                'bg-blue-500 shadow-lg shadow-blue-500/50': filter.active,
              }"
              class="menu_filter"
              @click="handleFilterClick(filter)"
            >
              {{ filter.name }}
            </button>
          </template>
        </div>
      </div>

      <!-- Content -->
      <div class="row-start-2 col-start-2">
        <div
          class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 grid-rows-[max-content_0fr] overflow-auto h-[72rem] ml-10"
        >
          <template
            v-if="section !== 'deals'"
            v-for="(item, key) in listItems[this.section]"
            :key="key"
          >
            <ProuctBox
              :menuID="item.menuID"
              :title="item.title"
              :image="item.image"
              :description="item.description"
              :avgRating="item.avgRating"
              :filters="filters"
              :ingredients="item.ingredients"
              :nutritionalInfo="item.nutritionalInfo"
              :allergyInfo="item.allergyInfo"
              :IsVegan="item.IsVegan"
              :IsVegetarian="item.IsVegetarian"
              :spiceLevel="item.spiceLevel"
              :price="item.price"
              :onSale="item.onSale"
              :discount="item.discount"
              :dealDescription="item.dealDescription"
              :count.sync="item.count"
              @count-updated="handleAddToOrder"
            />
          </template>
        </div>
      </div>

      <!-- Deals if categorySelected is deals -->
      <div v-if="section === 'deals'" class="row-start-2 col-start-2 mt-4">
        <div
          class="grid grid-cols-4 grid-rows-[max-content_0fr] overflow-auto h-[40rem] ml-10 mr-10 gap-4"
        >
          <template v-for="(deal, index) in deals" :key="index">
            <Deal :data="deal" />
          </template>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { ref, onMounted } from "vue";
import Sidenav from "../components/Sidenav.vue";
import Header from "../components/Header.vue";
import ProuctBox from "../components/ProductBox.vue";
import Deal from "../components/Deal.vue";

import { getCategories, getMenuByCategory, getDeals } from "../data/database";

export default {
  components: { Sidenav, Header, ProuctBox, Deal },
  setup() {
    const categories = ref([]);
    const section = ref("pasta"); // Set default section to "pasta"
    const listItems = ref({});
    const activeData = ref([]);
    const deals = ref([]);
    const filters = ref([
      { name: "Lactose Free", value: "dairy", active: false },
      { name: "Gluten Free", value: "gluten", active: false },
      { name: "Shellfish Free", value: "shellfish", active: false },
      { name: "Nut Free", value: "nuts", active: false },
      { name: "Soy Free", value: "soy", active: false },
    ]);
    const currentOrder = ref(JSON.parse(localStorage.getItem("order")) || []);
    const searchQuery = ref("");

    const getLoggedInUserFromCookie = () => {
      // Return null if no user cookie is found
      if (
        !document.cookie
          .split(";")
          .some((item) => item.trim().startsWith("user="))
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

    const setFiltersBasedOnUserPreferences = (allergies) => {
      // Set filters based on user preferences
      filters.value.forEach((filter) => {
        filter.active = allergies.includes(filter.value);
      });

      // Load items based on the updated filters
      loadCategoryItems();
    };

    // Load categories and default section items on mount
    onMounted(async () => {
      try {
        categories.value = await getCategories();
        console.log("Categories loaded:", categories.value);

        // Load pasta items by default
        const defaultCategory = categories.value.find(
          (category) => category.Path === section.value
        );
        if (defaultCategory) {
          // Get deals menu id
          await handleCategorySelected(defaultCategory.Path);
        }
        if (user?.Preferences?.Allergies) {
          const allergiesArray = user.Preferences.Allergies.toLowerCase()
            .split(",")
            .map((allergy) => allergy.trim());
          setFiltersBasedOnUserPreferences(allergiesArray);
        }

        // Get the deal menu count
        deals.value = await getDeals();
        console.log("Deals loaded:", deals.value);
      } catch (error) {
        console.error("Error loading categories or default items:", error);
      }
    });

    const handleCategorySelected = async (path) => {
      section.value = path;
      const selectedCategory = categories.value.find(
        (category) => category.Path === path
      );

      if (selectedCategory) {
        const categoryId = selectedCategory.CategoryId;
        try {
          const data = await getMenuByCategory(categoryId);
          activeData.value = data;
          loadCategoryItems(); // Load items once data is set
        } catch (error) {
          console.error("Error fetching menu by category:", error);
        }
      } else {
        console.error("Category not found for path:", path);
      }
    };

    const handleSearchUpdated = (query) => {
      searchQuery.value = query;
      console.log("Search query updated:", searchQuery.value);
      filterItemsBySearch();
    };
    const filterItemsBySearch = () => {
      if (!listItems.value[section.value]) return;

      // If query is empty, reset the list
      if (!searchQuery.value) {
        listItems.value[section.value] = activeData.value.reduce(
          (acc, item, index) => {
            acc[`${section.value}${index + 1}`] = {
              menuID: item.MenuID,
              title: item.Name,
              description: item.Description,
                avgRating: parseInt(item.Rating.AverageRating, 10),
              image: item.Image,
              ingredients: item.Ingredients,
              nutritionalInfo: item.NutritionalInfo,
              allergyInfo: item.AllergyInfo,
              IsVegetarian: item.IsVegetarian,
              IsVegan: item.IsVegan,
              spiceLevel: item.SpiceLevel,
              price: item.Price,
              onSale: item.DealDiscount !== null ? item.DealDiscount : false,
              discount: item.DealDiscount,
              dealDescription: item.DealDescription,
              count: item.count || 0,
            };
            return acc;
          },
          {}
        );
        return;
      }

      // Filter items in the current section based on the search query
      const filteredItems = Object.values(
        listItems.value[section.value]
      ).filter((item) =>
        item.title.toLowerCase().includes(searchQuery.value.toLowerCase())
      );

      // If no items match, switch to another category that contains matching items
      if (filteredItems.length === 0) {
        let categoryFound = false;
        for (const category of categories.value) {
          // Get all items from the current category
          const categoryItems = Object.values(
            listItems.value[category.Path] || []
          );

          // Check if any item in this category matches the search query
          const categoryFilteredItems = categoryItems.filter((item) =>
            item.title.toLowerCase().includes(searchQuery.value.toLowerCase())
          );

          if (categoryFilteredItems.length > 0) {
            // If we found a match, switch to this category
            section.value = category.Path;
            // Ensure reactivity by using Vue.set
            listItems.value[category.Path] = categoryFilteredItems.reduce(
              (acc, item, index) => {
                acc[`${category.Path}${index + 1}`] = item;
                return acc;
              },
              {}
            );
            categoryFound = true;
            break;
          }
        }

        if (!categoryFound) {
          console.log("No items match your search.");
        }
      } else {
        // If items match in the current category, update the list for the current section
        listItems.value[section.value] = filteredItems.reduce(
          (acc, item, index) => {
            acc[`${section.value}${index + 1}`] = item;
            return acc;
          },
          {}
        );
      }
    };

    const loadCategoryItems = () => {
      console.log("Loading items for section:", section.value);
      listItems.value[section.value] = {}; // Clear previous items

      activeData.value.forEach((item, index) => {
        // Log the current item being processed
        console.log("Current Item:", item);

        // Ensure AllergyInfo is not empty and filter checks are case-insensitive
        const hasNoAllergy = filters.value.every((filter) => {
          if (!filter.active) return true; // If filter is not active, skip
          return (
            !item.AllergyInfo ||
            !item.AllergyInfo.toLowerCase().includes(filter.value.toLowerCase())
          );
        });

        // If user.Preferences is not null and has vegan or vegetarian set (1 for true, 0 for false), filter items
        if (user?.Preferences && user.CustomerID) {
          if (user.Preferences.IsVegan === 1 && !item.IsVegan) {
            return;
          }

          if (user.Preferences.IsVegetarian === 1 && !item.IsVegetarian) {
            return;
          }
        }

        if (hasNoAllergy) {
          listItems.value[section.value][`${section.value}${index + 1}`] = {
            menuID: item.MenuID,
            title: item.Name,
            description: item.Description,
            avgRating: parseInt(item.Rating.AverageRating, 10),
            image: item.Image,
            ingredients: item.Ingredients,
            nutritionalInfo: item.NutritionalInfo,
            allergyInfo: item.AllergyInfo,
            IsVegetarian: item.IsVegetarian,
            IsVegan: item.IsVegan,
            spiceLevel: item.SpiceLevel,
            price: item.Price,
            onSale: item.DealDiscount !== null ? item.DealDiscount : false,
            discount: item.DealDiscount,
            dealDescription: item.DealDescription,
            count: item.count || 0,
          };
        }
      });

      console.log("Updated listItems:", listItems.value[section.value]);
    };

    const handleAddToOrder = (item) => {
      console.log("Add to order:", JSON.stringify(item));

      // If the count is 0, remove the item from the order
      if (item.count === 0) {
        currentOrder.value = currentOrder.value.filter(
          (orderItem) => orderItem.title !== item.title
        );
      } else {
        // If item is already in the order, update the count
        const existingItemIndex = currentOrder.value.findIndex(
          (orderItem) => orderItem.title === item.title
        );
        if (existingItemIndex !== -1) {
          currentOrder.value[existingItemIndex].count = item.count;
        } else {
          // Otherwise, add the item to the order
          currentOrder.value.push(item);
        }
      }

      // Update the order in local storage
      localStorage.setItem("order", JSON.stringify(currentOrder.value));
    };

    const handleFilterClick = (filter) => {
      filter.active = !filter.active;
      loadCategoryItems();
    };

    return {
      categories,
      section,
      listItems,
      filters,
      activeData,
      currentOrder,
      handleCategorySelected,
      handleSearchUpdated,
      handleAddToOrder,
      handleFilterClick,
      deals,
      setFiltersBasedOnUserPreferences,
    };
  },
};
</script>
