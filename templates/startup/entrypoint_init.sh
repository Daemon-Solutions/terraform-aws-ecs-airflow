# installation of dependencies
python -m pip install awscli

echo "Starting the init"
airflow initdb

# add admin user if rbac enabled and not exists
if [[ "${RBAC_AUTH}" == "true" ]]; then
    amount_of_users=$(python -c 'import sys;print((sys.argv.count("│") // 7) - 1)' $(airflow list_users))
    if [[ "$amount_of_users" == "0" ]]; then
        echo "Adding admin users, users list is empty!"
        airflow create_user -r Admin -u ${RBAC_USERNAME} -e ${RBAC_EMAIL} -f ${RBAC_FIRSTNAME} -l ${RBAC_LASTNAME} -p ${RBAC_PASSWORD}
    else
        echo "No admin user added, users already exists!"
    fi
fi