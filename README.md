# Web Dashboard Stats

This repository combines both the frontend and backend components of the Web Dashboard Stats project.

## Repository Structure

This repository uses git submodules to manage the frontend and backend components:

- `frontend/`: Contains the frontend application
- `localbackend/`: Contains the backend application

## Getting Started

### Cloning the Repository

To clone this repository along with its submodules, use:

```bash
git clone --recurse-submodules https://your-repository-url.git
```

Or if you've already cloned the repository:

```bash
git submodule init
git submodule update
```

### Working with Submodules

Each submodule is a separate git repository. To make changes to a submodule:

1. Navigate to the submodule directory
2. Make your changes
3. Commit and push in the submodule repository
4. Return to the main repository directory
5. Commit the submodule reference update