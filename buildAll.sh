# Checks for missing downloaded files
#
# files are necessary from fips/openssl, and sqlcipher

fipsSslFiles="1"
sqlCipherFiles="1"
  echo ""

# Checks for the existance of opssl/fips files and offers to copy them from local resources 
# sets abortBuild = 1 if there are missing files and user chooses to abort build
checkforFipsFiles()
{
  if [ ! -e "$sslFiles" ] ||  [ ! -e "$fipsFiles" ]; then 

      echo ""
      echo "!!!! One or more of the fips download files are missing !!!!!"
      echo "" 
      echo "sslFiles = $sslFiles"
      echo "fipsFiles = $fipsFiles"
      echo ""

      echo "You have two options:"

      echo "Option y - Copy local (unofficial) openssl downlad files form this distribution"
      echo "Option n - Stop build so you can download the official files"
    echo ""

      read -p "press y or n : " yn
      case $yn in
        [Yy]* ) 
      echo "Copying local files"
      cp localFipsSslFiles/*.gz ./dev
        ;;
        [Yn]* ) 
          echo "you chose no"
          abortBuild=1
          ;;
        * ) echo "please choose";;
      esac

  fi
}

# Checks for the existance of sqlcipher files and offers to copy them from local resources 
# sets abortBuild = 1 if there are missing files and user chooses to abort build
checkForSqlcipherFiels()
{
  if [ ! -d "$sqlcipherFiles" ]; then 


      echo ""
      echo "!!!! One or more of the sqlCipher download files are missing !!!!!"
      echo "" 
      echo "sqlcipherFiles = $sqlcipherFiles"
      echo ""
      echo "You have two options:"
      echo "Option y - Copy local (unofficial) sqlCipher downlad files form this distribution"
      echo "Option n - Stop build so you can download the official files"
      echo ""

      read -p "press y or n : " yn
      case $yn in
        [Yy]* ) 
      echo "Copying local files"
      cp -r localFipsSslFiles/android-database-sqlcipher dev/android-database-sqlcipher && \
      cd dev/android-database-sqlcipher
        # Make sure cqlcipher files are RW
      chmod -R 777 ./
      cd ../..
      

        ;;
        [Yn]* ) 
          echo "you chose no"
          abortBuild=1
          ;;
        * ) echo "please choose";;
      esac

  fi
}

# This sets up environment vars to point to which openssl/fips we want to use
. ./setEnvOpensslFiles.sh



echo "using $OPENSSL_BASE.tar.gz"
echo "using $FIPS_BASE.tar.gz"

# fips/openssl files
sslFiles="dev/$OPENSSL_BASE.tar.gz"
fipsFiles="dev/$FIPS_BASE.tar.gz"


echo $sslFiles
echo $fipsFiles

# sqlcipher files

sqlcipherFiles="dev/android-database-sqlcipher"

# Checkfor existance of necessary files
checkforFipsFiles
checkForSqlcipherFiels 

if [ "$abortBuild" == 1 ]; then
  echo "******** Aborting build ************"

else

     echo "----------------------------------------------------------------------------------------------------------"
     echo "Compiling fipswrapper project"
     echo "----------------------------------------------------------------------------------------------------------"
    make buildfipswrapper
    echo ""
    echo "--- All files present and accounted for, proceeding with build ---"
    echo ""
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Preparing files"
    echo "----------------------------------------------------------------------------------------------------------"
   pwd
    cd dev/android-database-sqlcipher
       pwd
    android update project -p . --target 1
    cd ../..
    make prepare
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Compiling FIPS Module"
    echo "----------------------------------------------------------------------------------------------------------"
    make fips
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Compiling ssl files"
    echo "----------------------------------------------------------------------------------------------------------"
    make ssl
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Compiling sqlcipher files"
    echo "----------------------------------------------------------------------------------------------------------"
    make sqlcipher
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Compiling t2 files"
    echo "----------------------------------------------------------------------------------------------------------"
    make t2

    rsync -a dev/FipsWrapper/bin/fipswrapper.jar dev/android-database-sqlcipher/libs

    echo "----------------------------------------------------------------------------------------------------------"
    echo "Checking for artifacts produced"
    echo "----------------------------------------------------------------------------------------------------------"
    echo ""
    make check   
   echo "" 


 fi

