# cosc4606-project
Our submission for the database management system project at Laurentian University.

# Running the System on your Machine
If you are interested in running the project on your local machine, you can follow these few simple instructions to install dependencies, and start both the logic and presentation tier locally. 

> Disclaimer: The database, running on Amazon RDS MUST be running in order for the out-of-the-box system to work. Otherwise, you will need to start a local database on your own machine using the provided table definitions in the appendix, and update the database credentials in your .env file. 


## Steps
1. As the logic tier runs on Node.js, ensure you’ve installed it on your machine. (https://nodejs.org/en/about/previous-releases)
2. Clone the GitHub repository using either HTTPS or SSH (https://github.com/nbergeron1/restaurant-ordering-system)
3. In the root directory, create a new file called .env
4. Paste in the contents of the .env file as identified in the appendix.
> For security reasons, we will be disabling the database, as well as the email account at the end of the 2024 Fall term. Following this date, you will need to run a local database, and password resets would no longer send any emails from the cosc4606ros email account..
5. Once cloned, open a Terminal and make sure you are located in the project's root directory (restaurant-ordering-system). 
6. Before starting the server, we need to install all dependencies. Rather than manually installing the dependencies by navigating to api, frontend and the root directory one at a time, you can do them all at once from the root directory.
7. Run the command npm install concurrently --save-dev
8. Now run the command npm run install-all
9. Now, from the root directory, run the command npm run start
