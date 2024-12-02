// data/database.js
import axios from "axios";

const URI = "http://localhost:3000/api/";
//const URI = "https://restaurant-ordering-system-seven.vercel.app/api/";

// Fetch all customers
export function getCustomers() {
    console.log('Fetching all customers');
    const uri = URI + `customers`;
    // Return the promise from axios directly
    return axios.get(uri)
        .then(response => response.data)
        .catch(error => {
            console.error("Error fetching data:", error);
            throw error; // Re-throw error to handle it in the calling component
        });
}

export async function getCustomer(email) {
    const uri = URI + `customer/${email}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null; // or handle accordingly in the UI
    }
}

export async function addCustomer(customer) {
    const uri = URI + `customer`;
    try {
        await axios.post(uri, customer);
        return true;
    } catch (error) {
        console.error("Error inserting data:", error);
        return false;
    }
}

export async function loginCustomer(email, password) {
    const uri = URI + `customer/login`;
    const credentials = { email, password };
    try {
        const response = await axios.post(uri, credentials);
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function resetPassword(email) {
    const uri = URI + `customer/forgot-password`;
    try {
        await axios.post(uri, { email });
        return true;
    } catch (error) {
        return false;
    }
}

export async function getCategories() {
    const uri = URI + `categories`;
    try {
        const response = await axios.get(uri);
        // Add custom category Deals, ID 0 for deals
        response.data.push({ CategoryId: 0, Name: "Special Offers", Path: "deals" });``
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function getMenu() {
    const uri = URI + `menu`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function getMenuByCategory(category) {
    const uri = URI + `menu/${category}`;
    try {
        const response = await axios.get(uri);
        for (let i = 0; i < response.data.length; i++) {
            console.log("Getting rating for menu item", response.data[i]);
            response.data[i].Rating = await getAverageRating(response.data[i].MenuID);
        }
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function getDeals() {
    const uri = URI + `getDeals`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function getCustomerPreferences(cusId) {
    const uri = URI + `customerpreferences/${cusId}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        console.error("Error fetching data:", error);
        return null;
    }
}

export async function getLocations() {
    const uri = URI + `locations`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// Fetch all orders from specific customer on specific date
export async function getOrders(cusId, date) {
    const uri = URI + `orders/${cusId}/${date}`;
    try {
        console.log("Fetching orders for customer", cusId, "on date", date);
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// Add order to database for specific customer
export async function addOrder(order) {
    const uri = URI + `order`;
    try {
        await axios.post(uri, order);
        return true;
    } catch (error) {
        console.error("Error inserting data:", error);
        return false;
    }
}

// Update status of order
export async function updateOrderStatus(orderId, status) {
    const uri = URI + `order/${orderId}`;
    try {
        console.log("Updating order status to", status + " for order", orderId);
        await axios.put(uri, { status });
        return true;
    } catch (error) {
        console.error("Error updating data:", error);
        return false;
    }
}

// Get the highest order number
export async function getOrderNumber() {
    const uri = URI + `orders/highestId`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// Get all orders with specific status
export async function getOrdersByStatus(status) {
    const uri = URI + `ordersByStatus/${status}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

//Get all orders for a specific customer
export async function getOrdersByCustomer(cusId) {
    const uri = URI + `ordersByCustomer/${cusId}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// remove orders for guest
export async function removeGuestOrders(cusId) {
    const uri = URI + `ordersDeleteGuest/${cusId}`;
    try {
        await axios.delete(uri);
        return true;
    } catch (error) {
        return false;
    }
}

// Update customer preferences
export async function updateCustomerPreferences(cusId, preferences) {
    const uri = URI + `customerpreferences/${cusId}`;
    try {
        await axios.put(uri, preferences);
        return true;
    } catch (error) {
        console.error("Error updating data:", error);
        return false;
    }
}

// update customer details
export async function updateCustomerDetails(cusId, customer) {
    const uri = URI + `customer/${cusId}`;
    try {
        await axios.put(uri, customer);
        return true;
    } catch (error) {
        console.error("Error updating data:", error);
        return false;
    }
}

// check if password matches
export async function checkPassword(cusId, password) {
    const uri = URI + `check-password/${cusId}`;
    try {
        const response = await axios.post(uri, { password });
        console.log(response.data);
        return response.data;
    } catch (error) {
        return false;
    }
}

// Function that gets the average rating for a specific menu item, otherwise returns 0
export async function getAverageRating(menuId) {
    const uri = URI + `averageRating/${menuId}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// Get ratings for a specific menu item
export async function getRatings(menuId) {
    const uri = URI + `reviews/${menuId}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// Add rating for a specific menu item
export async function addRating(rating) {
    const uri = URI + `review`;
    try {
        await axios.post(uri, rating);
        return true;
    } catch (error) {
        return false;
    }
}

export async function getOrdersNoPayment(cusId) {
    const uri = URI + `ordersNoPayment/${cusId}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function getOrdersAlreadyPaid(cusId) {
    const uri = URI + `ordersAlreadyPaid/${cusId}`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

export async function addPayment(payment) {
    const uri = URI + `payment`;
    try {
        await axios.post(uri, payment);
        return true;
    } catch (error) {
        return false;
    }
}

export async function deleteCustomer(cusId) {
    const uri = URI + `customer/${cusId}`;
    try {
        await axios.delete(uri);
        return true;
    } catch (error) {
        return false;
    }
}

// add location
export async function addLocation(location) {
    const uri = URI + `location`;
    try {
        await axios.post(uri, location);
        return true;
    } catch (error) {
        return false;
    }
}

// delete location
export async function deleteLocation(locationId) {
    const uri = URI + `location/${locationId}`;
    try {
        await axios.delete(uri);
        return true;
    } catch (error) {
        return false;
    }
}

// update location
export async function updateLocation(locationId, location) {
    const uri = URI + `location/${locationId}`;
    try {
        await axios.put(uri, location);
        return true;
    } catch (error) {
        return false;
    }
}

// get reservation
export async function getReservations() {
    const uri = URI + `reservation`;
    try {
        const response = await axios.get(uri);
        return response.data;
    } catch (error) {
        return null;
    }
}

// add reservation
export async function addReservation(reservation) {
    const uri = URI + `reservation`;
    try {
        await axios.post(uri, reservation);
        return true;
    } catch (error) {
        return false;
    }
}

// delete reservation
export async function deleteReservation(reservationId) {
    const uri = URI + `reservation/${reservationId}`;
    try {
        await axios.delete(uri);
        return true;
    } catch (error) {
        return false;
    }
}

// Add new deal
export async function addDeal(deal) {
    const uri = URI + `deal`;
    try {
        await axios.post(uri, deal);
        return true;
    } catch (error) {
        return false;
    }
}

// Update deal
export async function updateDeal(dealId, deal) {
    const uri = URI + `deal/${dealId}`;
    try {
        await axios.put(uri, deal);
        return true;
    } catch (error) {
        return false;
    }
}

// Delete deal
export async function deleteDeal(dealId) {
    const uri = URI + `deal/${dealId}`;
    try {
        await axios.delete(uri);
        return true;
    } catch (error) {
        return false;
    }
}
