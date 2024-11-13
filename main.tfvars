ARM_CLIENT_ID = "${{ secrets.CLIENT_ID }}"
ARM_CLIENT_SECRET = "${{ secrets.CLIENT_SECRET }}"
ARM_TENANT_ID = "${{ secrets.SUBSCRIPTION_ID }}"
ARM_SUBSCRIPTION_ID = "${{ secrets.TENANT_ID }}"
COSMOS_DB_ACCOUNT = "${{ vars.COSMOS_DB_ACCOUNT}}"
COSMOS_DB_DATABASE = "${{ vars.COSMOS_DB_DATABASE}}"
COSMOS_DB_CONTAINER = "${{ vars.COSMOS_DB_CONTAINER}}"
RG_NAME = "${{ vars.RG_NAME}}"
RG_LOCATION = "${{ vars.RG_LOCATION}}"
LOCATION_ABBREVIATION = "${{ vars.RG_LOCATION}}"
ENVIRONMENT = "${{ github.env }}"
USER_ASSIGNED_CLIENT_ID = "${{ secrets.CLIENT_ID }}"