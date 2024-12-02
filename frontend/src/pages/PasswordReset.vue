<template>
    <!-- Password reset page -->
    <div class="grid grid-cols-1 h-screen place-items-center">
        <div class="w-full max-w-xs">
            <h1 class="text-2xl font-bold mb-4 text-center">Reset Password</h1>
            <div v-if="passwordReset">
                <p class="text-center text-green-500">Password changed. You can close this page now.</p>
            </div>
            <form v-else @submit.prevent="resetPassword" class="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2" for="password">
                        New Password
                    </label>
                    <input
                        v-model="newPassword"
                        type="password"
                        id="password"
                        placeholder="Enter new password"
                        required
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                    />
                </div>
                <div class="flex items-center justify-between">
                    <button
                        type="submit"
                        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
                    >
                        Reset Password
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>

<script>
export default {
  data() {
    return {
      newPassword: "",
      token: this.$route.query.token,
      passwordReset: false,
    };
  },
  methods: {
    async resetPassword() {
      const response = await fetch(
        "http://localhost:3000/api/customer/reset-password",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            token: this.token,
            password: this.newPassword,
          }),
        }
      );

      if (response.ok) {
        this.passwordReset = true;
      } else {
        alert("Failed to reset password");
      }
    },
  },
};
</script>
