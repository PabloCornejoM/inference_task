# Inference Model Deployment API

This project implements an API for serving in a inference ML model using the MLOps structure. 
Includes a simple version of all the requiremtents, testing, CI/CD, and a definition of the infrastructure for deployment on GCP.

## Structure of the repository

.
├── app/                    # FastApi application
├── tests/                  # Unit tests 
├── terraform/              # Infrastructure defined with Terraform 
├── Dockerfile              # Docker image for serving the API  
├── requirements.txt        # Python dependencies for venv  
├── .github/workflows/ci.yml # CI/CD GitHub Actions workflow
└── README.md

## Run Locally

1. Create a virtual environment:
   python -m venv venv  
   source venv/bin/activate  
   pip install -r requirements.txt  

2. Run the API:
   uvicorn app.main:app --reload  

   Open the auto-generated docs at: http://localhost:8000/docs  

3. Or with Docker:
   docker build -t model-api .  
   docker run -p 8000:8000 model-api  


## Run Tests

pytest

## CI/CD

The CI pipeline in `.github/workflows/ci.yml`:

- Installs dependencies  
- Runs all tests  
- Fails the pipeline if tests fail  

This workflow is triggered automatically on every push to GitHub.

## Infrastructure as Code (Terraform)

Inside the `terraform/` folder:

- Creates a Docker Artifact Registry repository  
- Deploys a Cloud Run service  
- Creates a service account with required roles  
- Adds basic monitoring (uptime checks and alerts)  

The code is written as if it were production-ready, but only simulates deployment.
The API is designed for synchronous inference calls, assuming the backend directly makes the request.

For monitoring use uptime checks to `/health` using Cloud Monitoring and alerts. 
For versioning Docker image tags in Artifact Registry and saved trained models.