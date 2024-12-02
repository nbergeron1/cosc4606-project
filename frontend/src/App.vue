<script setup lang="js">
import Toast from 'primevue/toast';
</script>

<template>
  <div class="justify-center items-center h-screen main-body">
    <!-- Toast -->
    <Toast />
    <!-- Main Content -->
    <router-view />
  </div>
</template>
