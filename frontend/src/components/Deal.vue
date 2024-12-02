<template>
<Card style="background-color: #f1f5f9">
    <template #title>
        <div class="flex justify-between">
            <span>{{ data.Title }}</span>
        </div>
    </template>
    <template #subtitle>
            <span style="height: 48px; overflow-y: auto; display: block;">{{ data.Description }}</span>
    </template>
    <template #footer>
        <div class="flex gap-4 mt-1">
            <Tag icon="pi pi-tag" :value="data.Discount * 100 + '%'"></Tag>

            <Tag
                icon="pi pi-calendar"
                :value="new Date(data.ValidUntil).toLocaleDateString('en-US')"
                severity="danger"
            ></Tag>
        </div>
    </template>
</Card>
</template>

<script setup>
import { defineProps, onMounted } from "vue";

import Card from "primevue/card";
import Tag from "primevue/tag";

const props = defineProps({
  data: Object,
});

onMounted(() => {
  console.log("Deal data:");
  console.log(props.data);
});
</script>
