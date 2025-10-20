# Define the help target
help:
		@echo "Available targets:"
		@echo "  tools   - Install necessary tools"
		@echo "  tofu       - Initialize Tofu"
		@echo "  set-github-vars - Set GitHub variables"
		@echo "  apply-tofu      - Apply Tofu configuration"
		@echo "  create-aliases  - Create command aliases"
		@echo "  bootstrap       - Run all targets to bootstrap the environment"

# Define the install-tools target
tools:
		@echo "Installing tools..."
		@curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone
		@curl -sS https://webi.sh/k9s | bash
		@curl -sS https://fluxcd.io/install.sh | bash

# Define the init-tofu target
tofu:
		@echo "Initializing Tofu..."
		@cd bootstrap && tofu init

# Define the set-github-vars target
set-github-vars:
		@echo "Setting GitHub variables..."
		@read -p "Enter your GitHub organization: " TF_VAR_github_org; \
		read -p "Enter your GitHub repository: " TF_VAR_github_repository; \
		read -s -p "Enter your GitHub token: " TF_VAR_github_token; \
		echo; \
		export TF_VAR_github_org=$$TF_VAR_github_org; \
		export TF_VAR_github_repository=$$TF_VAR_github_repository; \
		export TF_VAR_github_token=$$TF_VAR_github_token; \
		echo "GitHub Organization: $$TF_VAR_github_org"; \
		echo "GitHub Repository: $$TF_VAR_github_repository"; \
		echo "GitHub Token: [HIDDEN]"

# Define the apply-tofu target
apply-tofu:
		@echo "Applying Tofu configuration..."
		@tofu apply

# Define the create-aliases target
create-aliases:
		@echo "Creating aliases..."
		@alias kk="EDITOR='code --wait' k9s"
		@alias k=kubectl

# Define the bootstrap target to run all the above targets
init: tools tofu set-github-vars apply-tofu aliases
		@echo "Bootstrapping complete."