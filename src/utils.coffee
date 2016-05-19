class Utils
  safeMatchString: (strA, strB) =>
    return @commonString(strA) == @commonString(strB)
    
  commonString: (str="") =>
    return _.trim _.toLower str

module.exports = new Utils
