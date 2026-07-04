# Initialize git in your project folder (if you haven't already)
git init

# Add all your files to git
git add .

# Commit the files
git commit -m "Initial commit for LeadInfo"

# Connect to your new GitHub repository (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/leadinfo.git

# Push the code to GitHub
git branch -M main
git push -u origin main