import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import warnings as wr

cash_request_df = pd.read_csv("C:/Users/Khaled/Desktop/IRON HACK/project-1-ironhack-payments-en-master/project_dataset/extract - cash request - data analyst.csv")
fees_df = pd.read_csv("C:/Users/Khaled/Desktop/IRON HACK/project-1-ironhack-payments-en-master/project_dataset/extract - fees - data analyst - .csv")


cash_request_df['user_id'] = cash_request_df['user_id'].fillna(cash_request_df['deleted_account_id'])

# Convert the 'created_at' column to datetime format for cohort analysis
cash_request_df['created_at'] = pd.to_datetime(cash_request_df['created_at'])

# Create a 'cohort_month' column to track the first cash request month for each user
cash_request_df['cohort_month'] = cash_request_df.groupby('user_id')['created_at'].transform('min').dt.to_period('M')

# Create a 'request_month' column to track the month of each request
cash_request_df['request_month'] = cash_request_df['created_at'].dt.to_period('M')

# Count the number of requests made by each cohort per request month
cohort_data = cash_request_df.groupby(['cohort_month', 'request_month']).size().unstack(fill_value=0)

# Display the cohort data
print(cohort_data.head())

# Create a new heatmap, but with a more readable scale and labels
plt.figure(figsize=(12, 8))

# Plot the normalized cohort data as a heatmap with annotations
sns.heatmap(cohort_data, cmap='Blues', annot=True, fmt='d', cbar=True, linewidths=0.5)

# Add labels and a clearer title
plt.title('Cohort Analysis - Frequency of Service Usage', fontsize=16)
plt.xlabel('Request Month')
plt.ylabel('Cohort Month')

# Show the plot
plt.show()

# Step 1: Merge the cash request dataset with the fees dataset using cash_request_id
merged_df = pd.merge(cash_request_df, fees_df, left_on='id', right_on='cash_request_id', how='left')

# Step 2: Filter for rows where the 'type' in the fees dataset is 'incident'
incident_df = merged_df[merged_df['type'] == 'incident']

# Step 3: Count the total number of requests and incidents for each cohort
total_requests_per_cohort = cash_request_df.groupby('cohort_month')['id'].count()
total_incidents_per_cohort = incident_df.groupby('cohort_month')['id_x'].count()

# Step 4: Calculate the incident rate for each cohort
incident_rate_per_cohort = (total_incidents_per_cohort / total_requests_per_cohort * 100).fillna(0)

# Display the incident rate for each cohort
incident_rate_per_cohort

# Step 1: Merge the cash request dataset with the fees dataset
merged_df = pd.merge(cash_request_df, fees_df, left_on='id', right_on='cash_request_id', how='left')

# Step 2: Filter for payment incidents (adjust 'incident' to match your actual type if needed)
incident_df = merged_df[merged_df['type'] == 'incident']

# Step 3: Calculate the number of requests and incidents per cohort
total_requests_per_cohort = cash_request_df.groupby('cohort_month')['id'].count()
total_incidents_per_cohort = incident_df.groupby('cohort_month')['id_x'].count()

# Step 4: Calculate the incident rate (incidents / total requests), then convert to percentage
incident_rate_per_cohort = (total_incidents_per_cohort / total_requests_per_cohort * 100).fillna(0)

# Step 5: Calculate the average incident rate across all cohorts
average_incident_rate = incident_rate_per_cohort.mean()

# Step 6: Plot the incident rate
plt.figure(figsize=(10, 6))
incident_rate_per_cohort.plot(kind='bar', color='skyblue')

# Step 7: Add an average line
plt.axhline(y=average_incident_rate, color='red', linestyle='--', label=f'Average ({average_incident_rate:.2f}%)')

# Add labels and title
plt.title('Incident Rate per Cohort with Average', fontsize=16)
plt.xlabel('Cohort Month', fontsize=12)
plt.ylabel('Incident Rate (%)', fontsize=12)

# Show legend
plt.legend()

# Show the plot
plt.show()



