#!/bin/bash
mkdir DBMS 2>> ./.error.log
clear
echo "-------------------------------------------"
echo "Database Management System using Bash Scripting"
echo "-------------------------------------------"
echo -e "\nThis Script is Written By:\n 1) Mohammed Saber \n 2) Ahmed Elazab"
function mainMenu() {
  echo -e "\n+---------Main Menu-------------+"
  echo "| 1. Create Database              |"
  echo "| 2. List Databases               |"
  echo "| 3. Connect To Database          |"
  echo "| 4. Drop Database                |"
  echo "| 5. Exit                         |"
  echo "+-------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  createDB ;;
    2)  list_DB  ;;
    3)  connect_DB ;;
    4)  dropDB ;;
    5)  exit ;;
    *)  echo " Wrong Choice " ; mainMenu;
  esac
}
createDB() {
  echo -e "Enter Database Name: \c"
  read dbName
  mkdir ./DBMS/$dbName
  if [[ $? == 0 ]]
  then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database $dbName"
  fi
  mainMenu
}

list_DB() {
    echo -e "\nAvailable Databases:"
    ls ./DBMS/
    mainMenu
}
connect_DB() {
  echo -e "Enter Database Name: \c"
  read dbName
  cd ./DBMS/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo "Database $dbName was Successfully Selected"
    tablesMenu
  else
    echo "Database $dbName wasn't found"
    mainMenu
  fi
}


function dropDB {
  echo -e "Enter Database Name: \c"
  read dbName
  rm -r ./DBMS/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo "Database Dropped Successfully"
  else
    echo "Database Not found"
  fi
  mainMenu
}

function tablesMenu {
  echo -e "\n+--------Tables Menu------------+"
  echo "| 1. Create a Table               |"
  echo "| 2. List Tables                  |"
  echo "| 3. Insert Into Table            |"
  echo "| 4. Drop Table                   |"
  echo "| 5. Select From Table            |"
  echo "| 6. Update Table                 |"
  echo "| 7. Delete From Table            |"
  echo "| 8. Back To Main Menu            |"
  echo "| 9. Exit                         |"
  echo "+-------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  createTable ;;
    2)  ls .; tablesMenu ;;
    3)  insert;;
    4)  dropTable;;
    5)  selectMenu ;;
    6)  updateTable;;
    7)  deleteFromTable;;
    8)  clear; cd ../.. 2>>./.error.log; mainMenu ;;
    9)  exit ;;
    *)  echo " Wrong Choice " ; tablesMenu;
  esac

}

function createTable {
  echo -e "Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "table already existed"
    tablesMenu
  fi
  echo -e "Number of Columns: \c"
  read colsNum
  counter=1
  sep="|"
  rSep="\n"
  pKey=""
  metaData="Field"$sep"Type"$sep"key"
  while [ $counter -le $colsNum ]
  do
    echo -e "Name of Column $counter: \c"
    read colName

    echo -e "Type of Column $colName: "
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done
    if [[ $pKey == "" ]]; then
      echo -e "Make PrimaryKey ? "
      select var in "yes" "no"
      do
        case $var in
          yes ) pKey="PK";
          metaData+=$rSep$colName$sep$colType$sep$pKey;
          break;;
          no )
          metaData+=$rSep$colName$sep$colType$sep""
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+=$rSep$colName$sep$colType$sep""
    fi
    if [[ $counter == $colsNum ]]; then
      temp=$temp$colName
    else
      temp=$temp$colName$sep
    fi
    ((counter++))
  done
  touch .$tableName
  echo -e $metaData  >> .$tableName
  touch $tableName
  echo -e $temp >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Table Created Successfully"
    tablesMenu
  else
    echo "Error Creating Table $tableName"
    tablesMenu
  fi
}

function insert {
  echo -e "Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table $tableName isn't existed "
    tablesMenu
  fi
  colsNum=`awk 'END{print NR}' .$tableName`
  sep="|"
  rSep="\n"
  for (( i = 2; i <= $colsNum; i++ )); do
    colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    echo -e "$colName ($colType) = \c"
    read data

    if [[ $colType == "int" ]]; then
      while ! [[ $data =~ ^[1-9][0-9]*$ ]]; do
        echo -e "invalid DataType "
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi
   
    if [[ $colType == "str" ]]; then
      while [[ -z "$data" ]]; do
        echo -e "The Value is Empty"
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi


    if [[ $colKey == "PK" ]]; then
      while [[ true ]]; do
        if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "invalid input for Primary Key !!"
        else
          break;
        fi
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi

    
    if [[ $i == $colsNum ]]; then
      row=$row$data$rSep
    else
      row=$row$data$sep
    fi
  done
  echo -e $row"\c" >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Error Inserting Data into Table $tableName"
  fi
  row=""
  tablesMenu
}

function dropTable {
  echo -e "Enter Table Name: \c"
  read tName
  rm $tName .$tName 2>>./.error.log
  if [[ $? == 0 ]]
  then
    echo "Table Dropped Successfully"
  else
    echo "Error Dropping Table $tName"
  fi
  tablesMenu
}


function selectMenu {
  echo -e "Enter Table Name: \c"
  read tName
  column -t -s '|' $tName 2>>./.error.log
  if [[ $? != 0 ]]
  then
    echo "Error During Displaying Table $tName"
  fi
  tablesMenu
}

function updateTable {
  echo -e "Enter Table Name: \c"
  read tName
  
  if ! [[ -f $tName ]]; then
    echo "Table $tName does not exist!"
    tablesMenu
  fi

  echo -e "Enter The Column name: \c"
  read field

  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ -z $fid ]]; then
    echo "Column not found"
    tablesMenu
  fi

  echo -e "Enter The Value: \c"
  read val
  d=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
  if [[ -z $d ]]; then
    echo "Value Not Found"
    tablesMenu
  else
    echo -e "Enter Field name to set: \c"
    read setField
    
    setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tName)
    if [[ -z $setFid ]]; then
      echo "Column '$setField' not found!"
      tablesMenu
    fi

    echo -e "Enter New Value to set: \c"
    read newValue

    colType=$(awk 'BEGIN{FS="|"}{if(NR=='$setFid'){print $2}}' .$tName)
    if [[ $colType == "int" && ! $newValue =~ ^[1-9][0-9]+$ ]]; then
      echo "Invalid Data Type! Expected an integer."
      tablesMenu
    fi

    NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tName 2>>./.error.log)
    oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tName 2>>./.error.log)
    
    echo $oldValue
    sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tName 2>>./.error.log
    echo "Row Updated Successfully"
    tablesMenu
  fi
}

function deleteFromTable {
  echo -e "Enter Table Name: \c"
  read tName
  if ! [[ -f $tName ]]; then
    echo "Error: Table '$tName' does not exist!"
    tablesMenu
  fi
  echo -e "Enter The Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ -z $fid ]]; then
    echo "Error: Column '$field' not found in table '$tName'!"
    tablesMenu
  else
    echo -e "Enter The Value: \c"
    read val
    d=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    if [[ $d == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
      sed -i ''$NR'd' $tName 2>>./.error.log
      echo "Row Deleted Successfully"
      tablesMenu
    fi
  fi
}
  
mainMenu
