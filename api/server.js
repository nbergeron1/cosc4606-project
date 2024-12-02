const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

require('dotenv').config();

// Initialize Express app
const app = express();

// Middleware
app.use(express.json()); // Allows handling JSON requests
app.use(cors()); // Enables Cross-Origin Resource Sharing (CORS) for your frontend

// MySQL connection
const connection = mysql.createConnection({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE,
    port: 3306,
    connectTimeout: 30000,  // Increase timeout for slow connections
});

connection.connect(function(err) {
    if (err) {
        console.error('Error connecting to the database:', err);
        return;
    }
    console.log('Connected to the database');
});

// Function to hash a password
async function hashPassword(password) {
    const saltRounds = 10; // The cost of processing the data
    const hash = await bcrypt.hash(password, saltRounds);
    return hash; // Return the hashed password
}

// Function to verify the password
async function verifyPassword(storedHash, inputPassword) {
    const match = await bcrypt.compare(inputPassword, storedHash);
    return match; // Return true if the password matches
}

// API to request a password reset
app.post('/api/customer/forgot-password', async (req, res) => {
    const { email } = req.body;

    console.log('Request to reset password for:', email);

    // Check if the user exists
    const query = 'SELECT * FROM customers WHERE Email = ?';
    connection.query(query, [email], (err, results) => {
        if (err || results.length === 0) {
            return res.status(404).send('User not found');
        }

        const user = results[0];
        // Generate a token and expiration date
        const token = crypto.randomBytes(20).toString('hex');
        const expiration = Date.now() + 3600000; // 1 hour expiration

        const expirationDate = new Date(expiration).toISOString().slice(0, 19).replace('T', ' ');

        // Store the token and expiration in the database
        const updateQuery = 'UPDATE customers SET reset_token = ?, reset_token_expiration = ? WHERE Email = ?';

        console.log('Updating user data with token:', token);

        connection.query(updateQuery, [token, expirationDate, email], (err) => {
            if (err) {
                console.error('Error updating user data:', err);
                return res.status(500).send('Error updating user data');
            }

            // Send email
            const transporter = nodemailer.createTransport({
                service: 'gmail',
                auth: {
                    user: process.env.EMAIL_USER,
                    pass: process.env.EMAIL_PASSWORD,
                },
            });

            const mailOptions = {
                from: process.env.EMAIL_USER,
                to: email,
                subject: 'Password Reset Request',
                text: `You requested a password reset.

                Click the following link to reset your password:
                http://`+process.env.PRODUCTION_LINK+`/#/reset-password?token=${token}

                This link will expire in one hour. If you did not request a password reset, please ignore this email.`,

            };
            console.log('Sending email:', mailOptions);

            transporter.sendMail(mailOptions, (error) => {
                if (error) {
                    console.log('Error sending email:', error);
                    return res.status(500).send('Error sending email');
                }
                console.log('Password reset email sent');
                res.status(200).send('Password reset email sent');
            });
        });
    });
});

app.post('/api/customer/reset-password', (req, res) => {
    const { token, password } = req.body;

    // Check if the token is valid and not expired
    const query = 'SELECT * FROM customers WHERE reset_token = ? AND reset_token_expiration > ?';
    connection.query(query, [token, Date.now()], (err, results) => {
        if (err || results.length === 0) {
            return res.status(400).send('Invalid or expired token');
        }

        const user = results[0];
        const hashedPassword = bcrypt.hashSync(password, 10); // Hash the new password

        // Update the password and clear the token
        const updateQuery = 'UPDATE customers SET Password = ?, reset_token = NULL, reset_token_expiration = NULL WHERE Email = ?';
        connection.query(updateQuery, [hashedPassword, user.Email], (err) => {
            if (err) {
                return res.status(500).send('Error updating password');
            }
            res.status(200).send('Password has been reset successfully');
        });
    });
});

// API call to see if input matches user's current password
app.post('/api/check-password/:cusId', async (req, res) => {
    const { password } = req.body;
    const cusId = req.params.cusId;
    const query = 'SELECT * FROM customers WHERE CustomerID = ?';
    connection.query(query, [cusId], async (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            return res.status(500).send('Error fetching data from database');
        }

        if (results.length > 0) {
            const customer = results[0];
            console.log('Checking if password matches for:', customer.Email);
            const isMatch = await verifyPassword(customer.Password, password); // Verify the password
            console.log('Password matches:', isMatch);
            if (isMatch) {
                return res.status(200).send(true);
            } else {
                return res.status(200).send(false);
            }
        } else {
            console.log('Customer not found');
            return res.status(404).send('Customer not found');
        }
    });
});

// Define the API route to get customers
app.get('/api/customers', (req, res) => {
    const query = 'SELECT * FROM customers'; // Replace with your actual table name
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

// API to get a single customer from a provided email
app.get('/api/customer/:email', (req, res) => {
    const email = req.params.email;
    const query = 'SELECT * FROM customers WHERE Email = ?';
    connection.query(query, [email], (err, results) => {
        if (err) {
            // Handle the error
        } else {
            // if have results
            if (results.length > 0) {
                res.json(results[0]);
                console.log(results[0]);
            } else {
                res.status(404).send('Customer not found');
                console.log('Customer not found');
            }
        }
    });
});

app.post('/api/customer', async (req, res) => {
    const { name, email, phone, address, password } = req.body; // Make sure to get the password from the request body
    const hashedPassword = await hashPassword(password); // Hash the password
    const query = 'INSERT INTO customers (name, email, phone, address, Password) VALUES (?, ?, ?, ?, ?)';

    connection.query(query, [name, email, phone, address, hashedPassword], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Customer added to database');
            console.log('Customer added to database with ID:', results.insertId);
        }
    });
});

app.post('/api/customer/login', async (req, res) => {
    const { email, password } = req.body;
    const query = 'SELECT * FROM customers WHERE Email = ?';

    connection.query(query, [email], async (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            if (results.length > 0) {
                const customer = results[0];
                const isMatch = await verifyPassword(customer.Password, password); // Verify the password
                if (isMatch) {
                    console.log('Customer logged in:', customer);
                    res.json(customer);
                } else {
                    res.status(401).send('Invalid password');
                }
            } else {
                res.status(404).send('Customer not found');
            }
        }
    });
});

app.get('/api/categories', (req, res) => {
    const query = 'SELECT * FROM categories'; // Replace with your actual table name
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

app.get('/api/menu', (req, res) => {
    const query = 'SELECT * FROM menu'; // Replace with your actual table name
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

app.get('/api/menu/:category', (req, res) => {
    const category = req.params.category;
    const query = `
        SELECT
            menu.*,
            menuattributes.*,
            deals.Title as DealTitle,
            deals.Description as DealDescription,
            deals.Discount as DealDiscount,
            deals.ValidUntil as DealValidUntil
        FROM
            menu
        LEFT JOIN
            menuattributes ON menu.MenuID = menuattributes.MenuID
        LEFT JOIN
            deals ON menu.MenuID = deals.MenuID
        WHERE
            menu.CategoryID = ?
    `;
    connection.query(query, [category], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

app.get('/api/getDeals', (req, res) => {
    const query = `SELECT * FROM deals
    `;
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

app.get('/api/customerpreferences/:cusId', (req, res) => {
    const cusId = req.params.cusId;
    const query = 'SELECT * FROM customerpreferences WHERE CustomerID = ?';
    connection.query(query, [cusId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            if (results.length > 0) {
                res.json(results[0]);
            } else {
                res.status(404).send('Customer preferences not found');
            }
        }
    });
});

app.get('/api/locations', (req, res) => {
    const query = 'SELECT * FROM location';
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

// Add order to database for specific customer
app.post('/api/order', (req, res) => {
    const order = req.body;
    const query = 'INSERT INTO orders (OrderStatus, OrderData, TotalAmount, CustomerID, GuestID, LocationID, OrderType) VALUES (?, ?, ?, ?, ?, ?, ?)';
    connection.query(query, [order.OrderStatus, order.OrderData, order.TotalAmount, order.CustomerID, order.GuestID, order.LocationID, order.OrderType], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Order added to database');
            console.log('Order added to database with ID:', results.insertId);
        }
    });
});

// Update status of order
app.put('/api/order/:orderId', (req, res) => {
    const orderId = req.params.orderId;
    const { status } = req.body;
    const query = 'UPDATE orders SET OrderStatus = ? WHERE OrderID = ?';
    connection.query(query, [status, orderId], (err) => {
        if (err) {
            console.error('Error updating data:', err);
            res.status(500).send('Error updating data in database');
        } else {
            console.log('Order ' + orderId + ' updated to status:', status);
            res.status(200).send('Order updated successfully');
        }
    });
});

// API to get all orders for a specific customer or guest on a specific date
app.get('/api/orders/:id/:date', (req, res) => {
    const id = req.params.id;
    const date = req.params.date;
    const query = 'SELECT * FROM orders WHERE (CustomerID = ? OR GuestID = ?) AND DATE(OrderDate) = ?';
    connection.query(query, [id, id, date], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            console.log('Getting orders for customer or guest:', id, 'on date:', date);
            res.json(results);
        }
    });
});

// Get the highest OrderID in the orders table
app.get('/api/orders/highestId', (req, res) => {
    const query = 'SELECT MAX(OrderID) as HighestOrderID FROM orders';
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            console.log('Highest OrderID:', results[0].HighestOrderID);
            res.json(results[0]);
        }
    });
});

// Get all orders for a specific status
app.get('/api/ordersByStatus/:status', (req, res) => {
    const status = req.params.status;
    const dateToday = new Date().toISOString().slice(0, 10);
    const query = 'SELECT * FROM orders WHERE OrderStatus = ? AND DATE(OrderDate) = ?';
    connection.query(query, [status, dateToday], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            console.log('Getting orders with status:', status);
            res.json(results);
        }
    });
});

// delete orders for specific customer
app.delete('/api/ordersDeleteGuest/:guestId', (req, res) => {
    const guestId = req.params.guestId;
    const query = 'DELETE FROM orders WHERE GuestID = ?';
    connection.query(query, [guestId], (err) => {
        if (err) {
            console.error('Error deleting data:', err);
            res.status(500).send('Error deleting data from database');
        } else {
            console.log('Deleted orders for customer:', guestId);
            res.status(200).send('Orders deleted successfully');
        }
    });
});

// Get all orders for a specific customer
app.get('/api/ordersByCustomer/:cusId', (req, res) => {
    const cusId = req.params.cusId;
    const query = 'SELECT * FROM orders WHERE CustomerID = ?';
    connection.query(query, [cusId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            console.log('Getting orders for customer:', cusId);
            res.json(results);
        }
    });
});

// Update customer preferences (columns are IsVegan, IsVegetarian, Allergies)
app.put('/api/customerpreferences/:cusId', (req, res) => {
    const cusId = req.params.cusId;
    const updates = req.body;

    // First, check if the customer has preferences
    const query = 'SELECT * FROM customerpreferences WHERE CustomerID = ?';
    connection.query(query, [cusId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            return res.status(500).send('Error fetching data from database');
        }

        if (results.length === 0) {
            // Insert new row if no preferences exist
            const insertQuery = `
                INSERT INTO customerpreferences (CustomerID, IsVegan, IsVegetarian, Allergies)
                VALUES (?, ?, ?, ?)`;
            connection.query(insertQuery, [cusId, updates.IsVegan, updates.IsVegetarian, updates.Allergies], (err) => {
                if (err) {
                    console.error('Error inserting data:', err);
                    return res.status(500).send('Error inserting data into database');
                }
                console.log('Inserted new preferences for customer:', cusId);
                return res.status(201).send('Preferences added successfully');
            });
        } else {
            // Update existing preferences
            const columns = Object.keys(updates);
            const updateQueries = columns.map((column) => {
                return new Promise((resolve, reject) => {
                    const query = `UPDATE customerpreferences SET ${column} = ? WHERE CustomerID = ?`;
                    connection.query(query, [updates[column], cusId], (err) => {
                        if (err) {
                            console.error('Error updating column:', column, err);
                            reject(err);
                        } else {
                            console.log('Updated column:', column, 'with value:', updates[column]);
                            resolve();
                        }
                    });
                });
            });

            // Run updates and handle the response
            Promise.all(updateQueries)
                .then(() => {
                    console.log('Updated preferences for customer:', cusId);
                    res.status(200).send('Preferences updated successfully');
                })
                .catch((error) => {
                    console.error('Error during updates:', error);
                    res.status(500).send('Error updating preferences');
                });
        }
    });
});


app.put('/api/customer/:cusId', async (req, res) => {
    const cusId = req.params.cusId;
    const updates = req.body;

    if (updates.Password) {
        updates.Password = await hashPassword(updates.Password); // Encrypt the password
    }

    const updateColumns = (columns, index = 0) => {
        if (index >= columns.length) {
            console.log('Updated customer details for customer:', cusId);
            return res.status(200).send('Customer details updated successfully');
        }

        const column = columns[index];
        const query = `UPDATE customers SET ${column} = ? WHERE CustomerID = ?`;
        connection.query(query, [updates[column], cusId], (err) => {
            if (err) {
                console.error('Error updating data:', err);
                return res.status(500).send('Error updating data in database');
            }
            console.log('Updated column:', column, 'with value:', updates[column]);
            updateColumns(columns, index + 1);
        });
    };

    updateColumns(Object.keys(updates));
});

// ReviewID, MenuID, CustomerID, Rating, Comment, ReviewDate
// Method that pulls the average rating for a specific menu item (rating can be 1-5)
app.get('/api/averageRating/:menuId', (req, res) => {
    const menuId = req.params.menuId;
    const query = 'SELECT AVG(Rating) as AverageRating FROM dishreview WHERE MenuID = ?';
    connection.query(query, [menuId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            console.log('Average rating for menu item:', menuId, 'is:', results[0].AverageRating);
            res.json(results[0]);
        }
    });
});

// Get all the reviews for a specific menu item
app.get('/api/reviews/:menuId', (req, res) => {
    const menuId = req.params.menuId;
    const query = 'SELECT * FROM dishreview WHERE MenuID = ?';
    connection.query(query, [menuId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

// Add a review for a specific menu item
app.post('/api/review', (req, res) => {
    const review = req.body;
    const query = 'INSERT INTO dishreview (MenuID, CustomerID, Rating, Comment, ReviewDate) VALUES (?, ?, ?, ?, ?)';
    connection.query(query, [review.MenuID, review.CustomerID, review.Rating, review.Comment, review.ReviewDate], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Review added to database');
            console.log('Review added to database with ID:', results.insertId);
        }
    });
});

// a list of all orders from orders that do not have a matching row in payment with OrderID for a specific CustomerID
app.get('/api/ordersNoPayment/:cusId', (req, res) => {
    const cusId = req.params.cusId;
    const query = 'SELECT * FROM orders WHERE CustomerID = ? AND OrderID NOT IN (SELECT OrderID FROM payment)';
    connection.query(query, [cusId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

// get all orders that have a matching row in payment with OrderID for a specific CustomerID
app.get('/api/ordersAlreadyPaid/:cusId', (req, res) => {
    const cusId = req.params.cusId;
    const query = 'SELECT * FROM orders LEFT JOIN payment ON orders.OrderID=payment.OrderID WHERE orders.CustomerID = ? AND orders.OrderID IN (SELECT OrderID FROM payment)';
    connection.query(query, [cusId], (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

app.post('/api/payment', (req, res) => {
    const payment = req.body;
    const query = 'INSERT INTO payment (PaymentID, PaymentDate, Amount, Tip, PaymentMethod, OrderID) VALUES (?, ?, ?, ?, ?, ?)';
    connection.query(query, [payment.PaymentID, payment.PaymentDate, payment.Amount, payment.Tip, payment.PaymentMethod, payment.OrderID], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Payment added to database');
            console.log('Payment added to database with ID:', results.insertId);
        }
    });
});

// delete a customer
app.delete('/api/customer/:cusId', (req, res) => {
    const cusId = req.params.cusId;
    const query = 'DELETE FROM customers WHERE CustomerID = ?';
    connection.query(query, [cusId], (err) => {
        if (err) {
            console.error('Error deleting data:', err);
            res.status(500).send('Error deleting data from database');
        } else {
            console.log('Deleted customer:', cusId);
            res.status(200).send('Customer deleted successfully');
        }
    });
});

// add new location
app.post('/api/location', (req, res) => {
    const location = req.body;
    const query = 'INSERT INTO location (Address, City, Province, ZipCode, Phone) VALUES (?, ?, ?, ?, ?)';
    connection.query(query, [location.Address, location.City, location.Province, location.ZipCode, location.Phone], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Location added to database');
            console.log('Location added to database with ID:', results.insertId);
        }
    });
});

// edit location
app.put('/api/location/:locId', async (req, res) => {
    const locId = req.params.locId;
    const updates = req.body;

    const updateColumns = (columns, index = 0) => {
        if (index >= columns.length) {
            console.log('Updated location details for loc:', locId);
            return res.status(200).send('Location details updated successfully');
        }

        const column = columns[index];
        const query = `UPDATE location SET ${column} = ? WHERE LocationID = ?`;
        connection.query(query, [updates[column], locId], (err) => {
            if (err) {
                console.error('Error updating data:', err);
                return res.status(500).send('Error updating data in database');
            }
            console.log('Updated column:', column, 'with value:', updates[column]);
            updateColumns(columns, index + 1);
        });
    };

    updateColumns(Object.keys(updates));
});

// delete a location
app.delete('/api/location/:locId', (req, res) => {
    const locId = req.params.locId;
    const query = 'DELETE FROM location WHERE LocationID = ?';
    connection.query(query, [locId], (err) => {
        if (err) {
            console.error('Error deleting data:', err);
            res.status(500).send('Error deleting data from database');
        } else {
            console.log('Deleted location:', locId);
            res.status(200).send('Location deleted successfully');
        }
    });
});

// get all reservations
app.get('/api/reservation', (req, res) => {
    const query = 'SELECT * FROM reservation';
    connection.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).send('Error fetching data from database');
        } else {
            res.json(results);
        }
    });
});

// add new reservation
app.post('/api/reservation', (req, res) => {
    const reservation = req.body;
    console.log(reservation);
    const query = 'INSERT INTO reservation (Phone, ReservationDate, ReservationTime, NumberOfGuests, Notes, LocationID) VALUES (?, ?, ?, ?, ?, ?)';
    connection.query(query, [reservation.Phone, reservation.ReservationDate, reservation.ReservationTime, reservation.NumberOfGuests, reservation.Notes, reservation.LocationID], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Reservation added to database');
            console.log('Reservation added to database with ID:', results.insertId);
        }
    });
});

// delete a reservation
app.delete('/api/reservation/:resId', (req, res) => {
    const resId = req.params.resId;
    const query = 'DELETE FROM reservation WHERE ReservationID = ?';
    connection.query(query, [resId], (err) => {
        if (err) {
            console.error('Error deleting data:', err);
            res.status(500).send('Error deleting data from database');
        } else {
            console.log('Deleted reservation:', resId);
            res.status(200).send('Reservation deleted successfully');
        }
    });
});

// add new deal
app.post('/api/deal', (req, res) => {
    const deal = req.body;
    const query = 'INSERT INTO deals (Title, Description, Discount, ValidUntil, MenuID) VALUES (?, ?, ?, ?, ?)';
    connection.query(query, [deal.Title, deal.Description, deal.Discount, deal.ValidUntil, deal.MenuID], (err, results) => {
        if (err) {
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data into database');
        } else {
            res.status(201).send('Deal added to database');
            console.log('Deal added to database with ID:', results.insertId);
        }
    });
});

// edit deal
app.put('/api/deal/:dealId', async (req, res) => {
    const dealId = req.params.dealId;
    const updates = req.body;

    const updateColumns = (columns, index = 0) => {
        if (index >= columns.length) {
            console.log('Updated deal details for deal:', dealId);
            return res.status(200).send('Deal details updated successfully');
        }

        const column = columns[index];
        const query = `UPDATE deals SET ${column} = ? WHERE DealID = ?`;
        connection.query(query, [updates[column], dealId], (err) => {
            if (err) {
                console.error('Error updating data:', err);
                return res.status(500).send('Error updating data in database');
            }
            console.log('Updated column:', column, 'with value:', updates[column]);
            updateColumns(columns, index + 1);
        });
    };

    updateColumns(Object.keys(updates));
});

// delete a deal
app.delete('/api/deal/:dealId', (req, res) => {
    const dealId = req.params.dealId;
    const query = 'DELETE FROM deals WHERE DealID = ?';
    connection.query(query, [dealId], (err) => {
        if (err) {
            console.error('Error deleting data:', err);
            res.status(500).send('Error deleting data from database');
        } else {
            console.log('Deleted deal:', dealId);
            res.status(200).send('Deal deleted successfully');
        }
    });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('Server is running on port 3000');
});

module.exports = app;
