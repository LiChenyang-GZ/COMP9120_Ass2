#!/usr/bin/env python3
import psycopg2

#####################################################
##  Database Connection
#####################################################

'''
Connect to the database using the connection string
'''


def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "userid"
    passwd = "password"
    myHost = "host"
    # 本地数据库连接参数
    # userid = ""  # 替换为你的本地数据库用户名
    # passwd = ""  # 替换为你的本地数据库密码
    # myHost = ""  # 本地数据库的主机名
    # database = ""  # 替换为你的本地数据库名称

    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                user=userid,
                                password=passwd,
                                host=myHost)
        # conn = psycopg2.connect(database=database,
        #                             user=userid,
        #                             password=passwd,
        #                             host=myHost)

    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)

    # return the connection to use
    return conn


'''
Validate staff based on username and password
'''


def checkLogin(login, password):
    conn = openConnection()
    cursor = conn.cursor()

    try:
        query = "SELECT * FROM check_login(%s, %s);"
        cursor.execute(query, (login, password))
        userInfo = cursor.fetchone()

        if userInfo:
            return userInfo
        else:
            return None
    except psycopg2.Error as e:
        print("Error executing query: ", e)
        return None

    finally:
        cursor.close()
        if conn:
            conn.close()

    # return ['jdoe', 'John', 'Doe', 'jdoe@csh.com']


'''
List all the associated admissions records in the database by staff
'''


def findAdmissionsByAdmin(login):
    conn = openConnection()
    cursor = conn.cursor()

    try:
        query = "SELECT * FROM find_Admissions_By_Admin(%s);"
        cursor.execute(query, (login,))
        admissions = cursor.fetchall()

        admissionlist = []
        for admission in admissions:
            admissionlist.append({
                'admission_id': admission[0],
                'admission_type': admission[1] if admission[1] is not None else '',
                'admission_department': admission[2] if admission[2] is not None else '',
                'discharge_date': admission[3] if admission[3] is not None else '',
                'fee': admission[4] if admission[4] is not None else '',
                'patient': admission[5] if admission[5] is not None else '',
                'condition': admission[6] if admission[6] is not None else ''
            })

        return admissionlist

    except psycopg2.Error as e:
        print("Error executing query: ", e)
        return None

    finally:
        cursor.close()
        if conn:
            conn.close()


# return


'''
Find a list of admissions based on the searchString provided as parameter
See assignment description for search specification
'''


def findAdmissionsByCriteria(searchString):
    conn = openConnection()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT * FROM find_admissions_by_criteria(%s)", (searchString,))
        admissions = cursor.fetchall()

        admissionlist = []
        for admission in admissions:
            admissionlist.append({
                'admission_id': admission[0],
                'admission_type': admission[1] if admission[1] is not None else '',
                'admission_department': admission[2] if admission[2] is not None else '',
                'discharge_date': admission[3] if admission[3] is not None else '',
                'fee': admission[4] if admission[4] is not None else '',
                'patient': admission[5] if admission[5] is not None else '',
                'condition': admission[6] if admission[6] is not None else ''
            })

        return admissionlist

    except psycopg2.Error as e:
        print("Error executing query: ", e)
        return None

    finally:
        cursor.close()
        conn.close()


'''
Add a new addmission 
'''


def addAdmission(type, department, patient, condition, admin):
    conn = openConnection()

    if conn is None:
        return False

    cursor = conn.cursor()

    try:
        cursor.callproc('add_admission', (type, department, patient, condition, admin))
        conn.commit()
        return True




    except psycopg2.Error as e:
        print("Error executing query: ", e)

    except psycopg2.Error as e:
        print("Error executing query: ", e)

    finally:
        cursor.close()
        conn.close()


'''
Update an existing admission
'''


def updateAdmission(id, type, department, dischargeDate, fee, patient, condition):
    conn = openConnection()

    if conn is None:
        return False

    cursor = conn.cursor()

    try:
        cursor.execute(
            "SELECT update_admission(%s::INTEGER, %s::VARCHAR, %s::VARCHAR, %s::DATE, %s::DECIMAL, %s::VARCHAR, %s::VARCHAR);",
            (
                int(id),
                str(type),
                str(department),
                dischargeDate if dischargeDate else None,
                float(fee) if fee else None,
                str(patient),
                str(condition) if condition else None
            ))

        conn.commit()
        return True

    except psycopg2.Error as e:
        print("Error executing query: ", e)

    finally:
        cursor.close()
        conn.close()


