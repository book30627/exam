#include <iostream>
#include <cstdlib> 
#include <ctime> 
#include <string>
#include <sstream>
/* run this program using the console pauser or add your own getch, system("pause") or input loop */
#include "mysql_connection.h"

#include <cppconn/driver.h>
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>

using namespace std;
string int2str(int &);
int main()
{
        sql::Driver *driver;
        sql::Connection *con;
        sql::Statement *stmt;
        sql::ResultSet *res;

        driver = get_driver_instance();
        con = driver->connect("localhost", "root", "");
        con->setSchema("my_db");

        stmt = con->createStatement();
        srand( time(NULL) );
    	string s;
    	for(int i=0;i<10;i++)
    	{
    	  s = int2str((rand() % 100) +1);		
          stmt->execute("INSERT INTO user(id,username,password,playername,level) VALUE("+"s"+"s"+"s"+"s"+"s"+")");
		}
//      execute 是用於無回傳值的情況，executeQuery則是有回傳值的情況使用
        return 0;
}
string int2str(int &i) {
	  string s;
	  stringstream ss(s);
	  ss << i;

	  return ss.str();
}
