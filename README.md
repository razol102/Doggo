<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
<a href="https://github.com/shir-tz/Doggo">
    <img src="documents/media/logo/Doggo Loggo.png" alt="Logo" width="200" height="200">
</a>

  <h3 align="center">IoT Seminar 2024</h3>

  <p align="center">
    Doggo: Mobile Application for Dog Owners
    <br />
    <a href="documents/Doggo Project Design.pdf"><strong>Explore the project design »</strong></a>
    <br />
    <a href="https://qr-code.click/i/p/66db5a8daeaf1">View Demo</a>
  </p>
</div>

## About The Project

Doggo is a mobile application that helps dog owners effortlessly monitor and manage their pet's health, activity, and well-being. Doggo empowers the owners to stay connected with their furry friends like never before. Whether you're tracking your dog's daily exercise, planning outdoor adventures, or scheduling important vet appointments. Doggo provides feedback, motivation, and rewards to dogs for their fitness activities and achievements.

Doggo comes with a compact attachment that easily fits onto your dog's collar or harness, tracking their activity and seamlessly communicating with the mobile app.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Key Features

* **Health & Activity Monitoring:** Track your dog’s exercise, and health with a collar attachment synced to the app.
* **Real-Time Feedback:** Get insights and rewards for your dog’s fitness achievements.
* **Community & Socialization:** Connect with local dog owners, schedule group walks, and track who’s at nearby parks.
* **Safety Features:** Set location-based alerts for your dog’s safety.
* **Adventure Planning:** Plan and track outdoor activities with your dog.
* **Seamless Sync:** Real-time data updates from collar to app.
* **Vet Scheduling:** Easily manage vet appointments and health reminders.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Technologies Used

<a href="https://www.arduino.cc/">
    <img src="https://content.arduino.cc/assets/arduino_logo_1200x630-01.png" alt="Arduino" width="120" height="63" style="margin-right: 10px;">
</a>
<a href="https://isocpp.org/">
    <img src="https://isocpp.org/assets/images/cpp_logo.png" alt="C++" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://flutter.dev/">
    <img src="https://cdn.prod.website-files.com/5ee12d8d7f840543bde883de/5ef3a1148ac97166a06253c1_flutter-logo-white-inset.svg" alt="Flutter" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://dart.dev/">
    <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGMoD0krhoeqgNfJPWBUAWpv-_ODWZzvspAQ&s" alt="Dart" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://www.android.com/">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Android_logo_2019_%28stacked%29.svg/1173px-Android_logo_2019_%28stacked%29.svg.png" alt="Android" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://www.python.org/">
    <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAojdfiU-YTTglyAywGexed1DmziFkV5v1Yg&s" alt="Python" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://flask.palletsprojects.com/en/3.0.x/">
    <img src="https://icon2.cleanpng.com/20180829/okc/kisspng-flask-python-web-framework-representational-state-flask-stickker-1713946755581.webp" alt="Flask" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://aws.amazon.com/?nc2=h_lg">
    <img src="https://www.logo.wine/a/logo/Amazon_Web_Services/Amazon_Web_Services-Logo.wine.svg" alt="AWS" width="63" height="63" style="margin-right: 10px;">
</a>
<a href="https://www.postgresql.org/">
    <img src="https://banner2.cleanpng.com/20180806/zfw/14bf5c27fba8b9edf714de03166cc8fb.webp" alt="PostgreSQL" width="100" height="63">
</a>


<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Getting Started
### Prerequisites
Before you begin, ensure you have met the following requirements:

* Docker: Installed and running
* AWS CLI (if deploying to AWS)

### Getting Started with Docker
#### 1. Download and Run the Docker Image
You don’t need to configure the app or deal with credentials. Simply pull and run the pre-built Docker image from Docker Hub.

##### Pull the Docker Image
To download the Docker image:
```bash
docker pull niznaor/doggo-app:latest
```

##### Run the Docker Container
To run the container and expose the app on port 5000:
```bash
docker run -d -p 5000:5000 niznaor/doggo-app:latest
```
This command will start the Flask application inside a Docker container, and you can access it at http://localhost:5000.

### Deployment on AWS EC2 (Optional)
If you want to deploy the Docker container to AWS EC2:

##### 1. SSH into your EC2 instance

##### 2. Install Docker on your EC2 instance (if not already installed)
```bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
```

##### 3. Log out and log back in to your EC2 instance to apply the changes.

##### 4. Pull the Docker image from Docker Hub
```bash
docker pull your-dockerhub-username/backend-demo
```

##### 5. Run the Docker container on EC2
```bash
docker run -d -p 80:5000 --name backend-demo your-dockerhub-username/backend-demo
```

This will expose the Flask application on port 80 of your EC2 instance.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Project Builders

Doggo was built by the following individuals:
* [Shir Tzfania](https://github.com/shir-tz) - shir.tzfania@gmail.com
* [Nizan Naor](https://github.com/NizCom) - nizan.naor11@gmail.com
* [Raz Olewsky](https://github.com/razol102) - raz12316@gmail.com


Project Link: [https://github.com/shir-tz/Doggo](https://github.com/shir-tz/Doggo)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

We would like to extend our heartfelt gratitude to the following individuals who have significantly contributed to the success of the Doggo project:

* **Nala (Dog):** For being the inspiring model for our collar design, and for her patience and cooperation throughout the process.
* **Gili Kamma:** For serving as a mentor, providing guidance and support that greatly enhanced our project’s development and execution.
* **Lior Zimmet:** For providing invaluable assistance in selecting the embedded components and offering expert electronic support, ensuring our project met its technical goals.
* **Stav Arcusin:** For expertly 3D printing the collar box, adding a crucial and well-crafted element to our final product.
* **Arad Aizen:** For his dedicated electronic support, helping to troubleshoot and refine the technical aspects of our project.
<p align="right">(<a href="#readme-top">back to top</a>)</p>
