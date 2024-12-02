<template>
    <Header title="How many are dining today?" />

    <div class="grid grid-rows-2 grid-col-2 justify-center items-center">

        <div class="col-span-2 m-12 h-[40rem]">

            <!-- Name grid -->
            <div v-if="diners.length > 0"
                class="diners_grid"
                :class="computedColumnsClass + ' grid_names'">
                <div v-for="(diner, index) in diners" :key="index" class="flex justify-self-end m-5">
                    <div class="text-5xl text-white mr-2">{{ diner.name }}</div>

                    <div class="">
                        <!-- Button to set as child -->

                        <button @click="setChild(index)"
                            :class="{ 'bg-green-300 rounded-full': diner.child, 'bg-gray-300 rounded-full': !diner.child }"
                            class="items-center justify-center ml-2">
                            <font-awesome-icon class="text-4xl text-gray-500 p-1 px-2 rounded-full"
                                icon="fa-solid fa-baby" />
                        </button>
                        <!-- Button to remove an entry -->
                        <button @click="removeDiner(index)" class="items-center justify-center ml-[10px]">
                            <font-awesome-icon class="text-3xl text-red-500 bg-red-200 rounded-full p-2 px-3"
                                icon="fa-solid fa-trash-alt" />
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="absolute right-[47.5rem] mt-[14rem]">

            <input type="text" v-model="newDinerName" placeholder="Type name..." class="input_diners rounded-[1.2rem] mb-6">

            <!-- Button to add more people  -->
            <button @click="addDiner" class="btn_lg">
                <font-awesome-icon class="text-4xl text-green-500 bg-green-200 rounded-full pr-1 pl-1"
                    icon="fa-solid fa-plus" />
                <span class="text_lg">Add Guest</span>
            </button>

            <!-- Button to next screen -->
            <button @click="saveToLocalStorage" class="btn_lg">
                <router-link to="/sushi">
                    <span class="text_lg">Done</span>
                    <font-awesome-icon class="text-4xl text-white" icon="fa-solid fa-caret-right" />
                </router-link>
            </button>
            <div class="flex m-2 justify-end">
                <p class="ml-4 text-3xl text-white font-bold mr-2">Total:</p>
                <p class="text-3xl text-white font-bold">{{ diners.length }}</p>
            </div>
        </div>



        <!-- Message that says age is subject to confirmation. -->
        <div class="absolute bottom-36 flex justify-center w-full">
            <p class="text_disclaimer ">Please note that age is subject to
                verification by the server. Only children under the age of 12 may will be permitted to eat at a discounted
                price. Customers who lie about their age may be asked to leave the restaurant.</p>
        </div>

    </div>
</template>

<script setup>
import Header from '../components/Header.vue';
</script>

<script>
export default {
    data() {
        return {
            diners: [{ name: '', child: false }],
            newDinerName: ''
        }
    },
    computed: {
        // Dynamically change the number of columns in the grid based on the number of diners
        computedColumnsClass() {
            if (this.diners.length >= 10) {
                return "grid-cols-3";
            } else if (this.diners.length >= 5) {
                return "grid-cols-2";
            } else {
                return "grid-cols-1";
            }
        },
    },
    methods: {
        // Add a new diner to the list
        addDiner() {
            if (this.newDinerName.trim() !== '') {
                this.diners.push({ name: this.newDinerName });
                this.newDinerName = '';
            }
        },
        // Remove a diner from the list
        removeDiner(index) {
            this.diners.splice(index, 1);
        },
        // Set a diner as a child
        setChild(index) {
            if (this.diners[index].child) {
                this.diners[index].child = false;
                console.log(this.diners[index].name + ' is not a child')
                return;
            }
            this.diners[index].child = true;
            console.log(this.diners[index].name + ' is a child')
        },
        // Save the diners to local storage
        saveToLocalStorage() {
            this.diners = this.diners.filter(diner => diner.name.trim() !== '');

            localStorage.setItem('diners', JSON.stringify(this.diners));
        }
    },
    watch: {
        diners: {
            // Save to local storage whenever the diners array changes
            handler() {
                this.saveToLocalStorage();
            },
            deep: true
        }
    },
    // Load the diners from local storage
    created() {
        const diners = localStorage.getItem('diners');
        if (diners) {
            this.diners = JSON.parse(diners);
        }
    }
}

</script>
