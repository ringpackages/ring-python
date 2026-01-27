/*
	Ring Python Test Suite
*/

load "stdlibcore.ring"

arch = getarch()
osDir = ""
archDir = ""
libName = ""
libVariant = ""

if isWindows()
	osDir = "windows"
	libName = "ring_python.dll"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	but arch = "x86"
		archDir = "i386"
	else
		raise("Unsupported Windows architecture: " + arch)
	ok
but isLinux()
	osDir = "linux"
	libName = "libring_python.so"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	else
		raise("Unsupported Linux architecture: " + arch)
	ok
	if isMusl()
		libVariant = "musl/"
	ok
but isFreeBSD()
	osDir = "freebsd"
	libName = "libring_python.so"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	else
		raise("Unsupported FreeBSD architecture: " + arch)
	ok
but isMacOSX()
	osDir = "macos"
	libName = "libring_python.dylib"
	if arch = "x64"
		archDir = "amd64"
	but arch = "arm64"
		archDir = "arm64"
	else
		raise("Unsupported macOS architecture: " + arch)
	ok
else
	raise("Unsupported OS! You need to build the library for your OS.")
ok

loadlib("../lib/" + osDir + "/" + libVariant + archDir + "/" + libName)

load "../src/python.ring"

func main
	new PythonTest()

func isMusl
	cOutput = systemCmd("sh -c 'ldd 2>&1'")
	return substr(cOutput, "musl") > 0

class PythonTest

	nPassed = 0 nFailed = 0 nAssertTotal = 0

	func init
		py_init()

		? "=========================================="
		? "   ring-python - Test Suite"
		? "=========================================="
		? ""

		testInitialization()
		testBasicExecution()
		testVariables()
		testModuleImport()
		testFunctionCalls()
		testMethodCalls()
		testAttributeAccess()
		testTypeChecking()
		testObjectIntrospection()
		testPythonConstants()
		testContainerCreation()
		testValueConversion()
		testComplexScenarios()
		testPythonClass()
		testPyObjectClass()
		testPyModuleClass()
		testPyNoneClass()
		testPyBoolClass()
		testPyListClass()
		testPyDictClass()
		testPyTupleClass()
		testPyValueClass()

		? ""
		? "=========================================="
		? "  Results: " + nPassed + "/" + nAssertTotal + " passed, " + nFailed + " failed"
		? "=========================================="

		if nFailed > 0
			raise("Test suite failed with " + nFailed + " failure(s)")
		ok

	func assert condition, cMessage
		nAssertTotal++
		if condition
			nPassed++
		else
			nFailed++
			? "  FAIL: " + cMessage
		ok

	func testInitialization
		? "--- Initialization ---"

		nInit = py_init()
		assert(nInit = 1, "py_init() should return 1")
		? "  py_init: " + nInit

		cVer = py_version()
		assert(isString(cVer) and len(cVer) > 0, "py_version() should return non-empty string")
		? "  py_version: " + cVer
		? ""

	func testBasicExecution
		? "--- Basic Execution ---"

		nExec = py_exec("x = 42")
		assert(nExec = 1, "py_exec() should return 1")
		? "  py_exec('x = 42'): " + nExec

		nArith = py_eval("2 + 2")
		assert(nArith = 4, "py_eval('2 + 2') should return 4")
		? "  py_eval('2 + 2'): " + nArith

		cConcat = py_eval("'hello' + ' ' + 'world'")
		assert(cConcat = "hello world", "py_eval() string concat should return 'hello world'")
		? "  py_eval string concat: " + cConcat

		aList = py_eval("[1, 2, 3]")
		assert(isList(aList) and len(aList) = 3, "py_eval() list should return list of 3")
		? "  py_eval list: " + len(aList) + " items"

		aDict = py_eval("{'a': 1, 'b': 2}")
		assert(isList(aDict), "py_eval() dict should return list of pairs")
		? "  py_eval dict: list of " + len(aDict) + " pairs"
		? ""

	func testVariables
		? "--- Variables (py_set / py_get) ---"

		py_set("mynum", 123)
		nNum = py_get("mynum")
		assert(nNum = 123, "py_set/py_get number should return 123")
		? "  number: " + nNum

		py_set("mystr", "hello from ring")
		cStr = py_get("mystr")
		assert(cStr = "hello from ring", "py_set/py_get string should match")
		? "  string: " + cStr

		py_set("mylist", [1, 2, 3])
		aList = py_get("mylist")
		assert(isList(aList) and len(aList) = 3, "py_set/py_get list should return list of 3")
		? "  list: " + len(aList) + " items"

		py_set("mydict", [["name", "ring"], ["version", 1]])
		aDict = py_get("mydict")
		assert(isList(aDict), "py_set/py_get dict should return list")
		? "  dict: list of " + len(aDict) + " pairs"
		? ""

	func testModuleImport
		? "--- Module Import ---"

		pMath = py_import("math")
		assert(isPointer(pMath), "py_import('math') should return pointer")
		? "  math: " + py_type(pMath)

		pJson = py_import("json")
		assert(isPointer(pJson), "py_import('json') should return pointer")
		? "  json: " + py_type(pJson)

		pOs = py_import("os")
		assert(isPointer(pOs), "py_import('os') should return pointer")
		? "  os: " + py_type(pOs)
		? ""

	func testFunctionCalls
		? "--- Function Calls (py_call) ---"

		nSqrt = py_call("math.sqrt", [16])
		assert(nSqrt = 4, "py_call('math.sqrt', [16]) should return 4")
		? "  math.sqrt(16): " + nSqrt

		nPow = py_call("math.pow", [2, 10])
		assert(nPow = 1024, "py_call('math.pow', [2, 10]) should return 1024")
		? "  math.pow(2, 10): " + nPow

		nLen = py_call("len", ["hello"])
		assert(nLen = 5, "py_call('len', ['hello']) should return 5")
		? "  len('hello'): " + nLen

		cDumps = py_call("json.dumps", [[["a", 1], ["b", 2]]])
		assert(isString(cDumps) and substr(cDumps, "a"), "py_call() json.dumps should return string with 'a'")
		? "  json.dumps: " + cDumps

		cKwargs = py_call("json.dumps", [[["x", 1]]], [["indent", 2]])
		assert(isString(cKwargs), "py_call() with kwargs should return string")
		? "  json.dumps with kwargs: OK"

		cJoin = py_call("os.path.join", ["/home", "user", "file.txt"])
		assert(cJoin = "/home/user/file.txt", "py_call() os.path.join should return correct path")
		? "  os.path.join: " + cJoin
		? ""

	func testMethodCalls
		? "--- Method Calls (py_call_method) ---"

		pStr = py_object("hello world")
		assert(isPointer(pStr), "py_object() should create pointer")
		? "  py_object('hello world'): pointer"

		cUpper = py_call_method(pStr, "upper", [])
		assert(cUpper = "HELLO WORLD", "str.upper() should return 'HELLO WORLD'")
		? "  upper: " + cUpper

		aSplit = py_call_method(pStr, "split", [])
		assert(isList(aSplit) and len(aSplit) = 2, "str.split() should return list of 2")
		? "  split: " + len(aSplit) + " parts"

		cReplace = py_call_method(pStr, "replace", ["world", "ring"])
		assert(cReplace = "hello ring", "str.replace() should return 'hello ring'")
		? "  replace: " + cReplace
		? ""

	func testAttributeAccess
		? "--- Attribute Access ---"

		pMath = py_import("math")

		nHas = py_hasattr(pMath, "pi")
		assert(nHas = 1, "py_hasattr(math, 'pi') should return 1")
		? "  hasattr(math, 'pi'): " + nHas

		nMissing = py_hasattr(pMath, "nonexistent")
		assert(nMissing = 0, "py_hasattr(math, 'nonexistent') should return 0")
		? "  hasattr(math, 'nonexistent'): " + nMissing

		nPi = py_getattr(pMath, "pi")
		assert(nPi > 3.14 and nPi < 3.15, "py_getattr(math, 'pi') should be ~3.14159")
		? "  getattr(math, 'pi'): " + nPi
		? ""

	func testTypeChecking
		? "--- Type Checking ---"

		pInt = py_object(42)
		cType = py_type(pInt)
		assert(cType = "int", "py_type(42) should return 'int'")
		? "  type(42): " + cType

		pFloat = py_object(3.14)
		cType = py_type(pFloat)
		assert(cType = "float", "py_type(3.14) should return 'float'")
		? "  type(3.14): " + cType

		pStr = py_object("test")
		cType = py_type(pStr)
		assert(cType = "str", "py_type('test') should return 'str'")
		? "  type('test'): " + cType

		nIs = py_isinstance(pInt, "int")
		assert(nIs = 1, "py_isinstance(42, 'int') should return 1")
		? "  isinstance(42, int): " + nIs

		nIsNot = py_isinstance(pInt, "str")
		assert(nIsNot = 0, "py_isinstance(42, 'str') should return 0")
		? "  isinstance(42, str): " + nIsNot
		? ""

	func testObjectIntrospection
		? "--- Object Introspection ---"

		pStr = py_object("hello world")

		cRepr = py_repr(pStr)
		assert(substr(cRepr, "hello"), "py_repr() should contain 'hello'")
		? "  repr: " + cRepr

		cStr = py_str(pStr)
		assert(cStr = "hello world", "py_str() should return 'hello world'")
		? "  str: " + cStr

		pList = py_list([1, 2, 3, 4, 5])
		nLen = py_len(pList)
		assert(nLen = 5, "py_len() should return 5")
		? "  len([1,2,3,4,5]): " + nLen

		pMath = py_import("math")
		aDir = py_dir(pMath)
		assert(isList(aDir) and len(aDir) > 10, "py_dir(math) should return list with >10 entries")
		? "  dir(math): " + len(aDir) + " entries"
		? ""

	func testPythonConstants
		? "--- Python Constants ---"

		pNone = py_none()
		assert(isPointer(pNone), "py_none() should return pointer")
		cType = py_type(pNone)
		assert(cType = "NoneType", "py_type(None) should return 'NoneType'")
		? "  None: type=" + cType

		pTrue = py_true()
		assert(isPointer(pTrue), "py_true() should return pointer")
		nVal = py_value(pTrue)
		assert(nVal = 1, "py_value(True) should return 1")
		? "  True: value=" + nVal

		pFalse = py_false()
		assert(isPointer(pFalse), "py_false() should return pointer")
		nVal = py_value(pFalse)
		assert(nVal = 0, "py_value(False) should return 0")
		? "  False: value=" + nVal
		? ""

	func testContainerCreation
		? "--- Container Creation ---"

		pList = py_list([10, 20, 30])
		assert(isPointer(pList), "py_list() should return pointer")
		assert(py_len(pList) = 3, "py_len(list) should return 3")
		assert(py_type(pList) = "list", "py_type(list) should return 'list'")
		? "  list([10,20,30]): len=" + py_len(pList) + " type=" + py_type(pList)

		pDict = py_dict([["key1", "value1"], ["key2", "value2"]])
		assert(isPointer(pDict), "py_dict() should return pointer")
		assert(py_len(pDict) = 2, "py_len(dict) should return 2")
		assert(py_type(pDict) = "dict", "py_type(dict) should return 'dict'")
		? "  dict: len=" + py_len(pDict) + " type=" + py_type(pDict)

		pTuple = py_tuple([1, 2, 3])
		assert(isPointer(pTuple), "py_tuple() should return pointer")
		assert(py_len(pTuple) = 3, "py_len(tuple) should return 3")
		assert(py_type(pTuple) = "tuple", "py_type(tuple) should return 'tuple'")
		? "  tuple([1,2,3]): len=" + py_len(pTuple) + " type=" + py_type(pTuple)

		assert(py_len(py_list([])) = 0, "empty py_list() should have len 0")
		assert(py_len(py_dict([])) = 0, "empty py_dict() should have len 0")
		assert(py_len(py_tuple([])) = 0, "empty py_tuple() should have len 0")
		? "  empty containers: all len=0"
		? ""

	func testValueConversion
		? "--- Value Conversion ---"

		pNum = py_object(12345)
		nVal = py_value(pNum)
		assert(nVal = 12345, "py_value(12345) should return 12345")
		? "  number round-trip: " + nVal

		pStr = py_object("test string")
		cVal = py_value(pStr)
		assert(cVal = "test string", "py_value('test string') should match")
		? "  string round-trip: " + cVal

		pList = py_object([1, 2, 3])
		aVal = py_value(pList)
		assert(isList(aVal) and aVal[1] = 1, "py_value([1,2,3]) should return Ring list")
		? "  list round-trip: " + len(aVal) + " items"

		pDict = py_object([["a", 100], ["b", 200]])
		aVal = py_value(pDict)
		assert(isList(aVal), "py_value(dict) should return Ring list")
		? "  dict round-trip: " + len(aVal) + " pairs"
		? ""

	func testComplexScenarios
		? "--- Complex Scenarios ---"

		cJson = '{"name": "Ring", "version": 1.21}'
		py_set("jsonstr", cJson)
		py_exec("import json; parsed = json.loads(jsonstr)")
		aParsed = py_get("parsed")
		assert(isList(aParsed), "JSON parse should return list")
		? "  JSON parse: " + len(aParsed) + " pairs"

		py_exec("import math; result = math.factorial(10)")
		nFact = py_get("result")
		assert(nFact = 3628800, "math.factorial(10) should return 3628800")
		? "  factorial(10): " + nFact

		py_exec("squares = [x**2 for x in range(5)]")
		aSquares = py_get("squares")
		assert(isList(aSquares) and len(aSquares) = 5 and aSquares[5] = 16, "list comprehension should return [0,1,4,9,16]")
		? "  list comprehension: " + len(aSquares) + " items"

		py_set("mystr", "hello from ring")
		py_exec("formatted = f'Hello {mystr}'")
		cFmt = py_get("formatted")
		assert(cFmt = "Hello hello from ring", "f-string should format correctly")
		? "  f-string: " + cFmt
		? ""

	func testPythonClass
		? "--- OOP: Python Class ---"

		oPy = new Python()

		cVer = oPy.version()
		assert(isString(cVer) and len(cVer) > 0, "Python.version() should return non-empty string")
		? "  version: " + cVer

		nExec = oPy.exec("oop_x = 99")
		assert(nExec = 1, "Python.exec() should return 1")
		? "  exec('oop_x = 99'): " + nExec

		nEval = oPy.eval("oop_x + 1")
		assert(nEval = 100, "Python.eval('oop_x + 1') should return 100")
		? "  eval('oop_x + 1'): " + nEval

		oPy.set("oop_name", "Ring")
		cName = oPy.getVar("oop_name")
		assert(cName = "Ring", "Python.set/getVar should round-trip")
		? "  set/getVar: " + cName

		pMod = oPy.importModule("math")
		assert(isPointer(pMod), "Python.importModule() should return pointer")
		? "  importModule('math'): pointer"

		cCwd = oPy.callFunc("os.getcwd")
		assert(isString(cCwd), "Python.callFunc() should return string")
		? "  callFunc('os.getcwd'): " + cCwd

		nSqrt = oPy.callFuncArgs("math.sqrt", [25])
		assert(nSqrt = 5, "Python.callFuncArgs('math.sqrt', [25]) should return 5")
		? "  callFuncArgs('math.sqrt', [25]): " + nSqrt

		cKw = oPy.callFuncKwargs("json.dumps", [["a",1]], [["indent",2]])
		assert(isString(cKw), "Python.callFuncKwargs() should return string")
		? "  callFuncKwargs: OK"
		? ""

	func testPyObjectClass
		? "--- OOP: PyObject Class ---"

		oObj = new PyObject(py_object("hello ring"))

		cType = oObj.type()
		assert(cType = "str", "PyObject.type() should return 'str'")
		? "  type: " + cType

		cStr = oObj.str()
		assert(cStr = "hello ring", "PyObject.str() should return 'hello ring'")
		? "  str: " + cStr

		cRepr = oObj.repr()
		assert(substr(cRepr, "hello ring"), "PyObject.repr() should contain 'hello ring'")
		? "  repr: " + cRepr

		nLen = oObj.len()
		assert(nLen = 10, "PyObject.len() should return 10")
		? "  len: " + nLen

		nIs = oObj.isinstance("str")
		assert(nIs = 1, "PyObject.isinstance('str') should return 1")
		? "  isinstance('str'): " + nIs

		nIsNot = oObj.isinstance("int")
		assert(nIsNot = 0, "PyObject.isinstance('int') should return 0")
		? "  isinstance('int'): " + nIsNot

		cVal = oObj.value()
		assert(cVal = "hello ring", "PyObject.value() should return 'hello ring'")
		? "  value: " + cVal

		aDir = oObj.dir()
		assert(isList(aDir) and len(aDir) > 5, "PyObject.dir() should return list with >5 entries")
		? "  dir: " + len(aDir) + " entries"

		nHas = oObj.hasattr("upper")
		assert(nHas = 1, "PyObject.hasattr('upper') should return 1")
		? "  hasattr('upper'): " + nHas

		nMissing = oObj.hasattr("nonexistent")
		assert(nMissing = 0, "PyObject.hasattr('nonexistent') should return 0")
		? "  hasattr('nonexistent'): " + nMissing

		xAttr = oObj.getattr("upper")
		assert(xAttr != NULL, "PyObject.getattr('upper') should return non-null")
		? "  getattr('upper'): OK"

		cUpper = oObj.callMethod("upper")
		assert(cUpper = "HELLO RING", "PyObject.callMethod('upper') should return 'HELLO RING'")
		? "  callMethod('upper'): " + cUpper

		cRepl = oObj.callMethodArgs("replace", ["ring", "world"])
		assert(cRepl = "hello world", "PyObject.callMethodArgs('replace') should return 'hello world'")
		? "  callMethodArgs('replace'): " + cRepl

		xEnc = oObj.callMethodArgs("encode", ["utf-8"])
		assert(xEnc != NULL, "PyObject.callMethodArgs('encode') should return non-null")
		? "  callMethodArgs('encode'): OK"
		? ""

	func testPyModuleClass
		? "--- OOP: PyModule Class ---"

		oMath = new PyModule("math")

		cType = oMath.type()
		assert(cType = "module", "PyModule.type() should return 'module'")
		? "  type: " + cType

		nHas = oMath.hasattr("pi")
		assert(nHas = 1, "PyModule.hasattr('pi') should return 1")
		? "  hasattr('pi'): " + nHas

		nPi = oMath.getattr("pi")
		assert(nPi > 3.14 and nPi < 3.15, "PyModule.getattr('pi') should be ~3.14159")
		? "  getattr('pi'): " + nPi

		nHasSqrt = oMath.hasattr("sqrt")
		assert(nHasSqrt = 1, "PyModule.hasattr('sqrt') should return 1")
		? "  hasattr('sqrt'): " + nHasSqrt

		aDir = oMath.dir()
		assert(isList(aDir) and len(aDir) > 10, "PyModule.dir() should return list with >10 entries")
		? "  dir: " + len(aDir) + " entries"
		? ""

	func testPyNoneClass
		? "--- OOP: PyNone Class ---"

		oNone = new PyNone()

		cType = oNone.type()
		assert(cType = "NoneType", "PyNone.type() should return 'NoneType'")
		? "  type: " + cType

		cStr = oNone.str()
		assert(cStr = "None", "PyNone.str() should return 'None'")
		? "  str: " + cStr

		cRepr = oNone.repr()
		assert(cRepr = "None", "PyNone.repr() should return 'None'")
		? "  repr: " + cRepr
		? ""

	func testPyBoolClass
		? "--- OOP: PyBool Class ---"

		oTrue = new PyBool(true)

		cType = oTrue.type()
		assert(cType = "bool", "PyBool(true).type() should return 'bool'")
		? "  PyBool(true) type: " + cType

		nVal = oTrue.value()
		assert(nVal = 1, "PyBool(true).value() should return 1")
		? "  PyBool(true) value: " + nVal

		cStr = oTrue.str()
		assert(cStr = "True", "PyBool(true).str() should return 'True'")
		? "  PyBool(true) str: " + cStr

		oFalse = new PyBool(false)

		nVal = oFalse.value()
		assert(nVal = 0, "PyBool(false).value() should return 0")
		? "  PyBool(false) value: " + nVal

		cStr = oFalse.str()
		assert(cStr = "False", "PyBool(false).str() should return 'False'")
		? "  PyBool(false) str: " + cStr
		? ""

	func testPyListClass
		? "--- OOP: PyList Class ---"

		oList = new PyList([10, 20, 30])

		cType = oList.type()
		assert(cType = "list", "PyList.type() should return 'list'")
		? "  type: " + cType

		nLen = oList.len()
		assert(nLen = 3, "PyList.len() should return 3")
		? "  len: " + nLen

		cStr = oList.str()
		assert(cStr = "[10, 20, 30]", "PyList.str() should return '[10, 20, 30]'")
		? "  str: " + cStr

		aVal = oList.value()
		assert(isList(aVal) and len(aVal) = 3, "PyList.value() should return Ring list of 3")
		? "  value: " + len(aVal) + " items"

		aCopy = oList.callMethod("copy")
		assert(isList(aCopy) and len(aCopy) = 3, "PyList.callMethod('copy') should return list of 3")
		? "  copy: " + len(aCopy) + " items"

		nCount = oList.callMethodArgs("count", [20])
		assert(nCount = 1, "PyList.callMethodArgs('count', [20]) should return 1")
		? "  count(20): " + nCount

		oEmpty = new PyList([])
		assert(oEmpty.len() = 0, "empty PyList should have len 0")
		? "  empty len: " + oEmpty.len()
		? ""

	func testPyDictClass
		? "--- OOP: PyDict Class ---"

		oDict = new PyDict([["name", "Ring"], ["year", 2016]])

		cType = oDict.type()
		assert(cType = "dict", "PyDict.type() should return 'dict'")
		? "  type: " + cType

		nLen = oDict.len()
		assert(nLen = 2, "PyDict.len() should return 2")
		? "  len: " + nLen

		cStr = oDict.str()
		assert(substr(cStr, "name"), "PyDict.str() should contain 'name'")
		? "  str: " + cStr

		aVal = oDict.value()
		assert(isList(aVal), "PyDict.value() should return Ring list")
		? "  value: " + len(aVal) + " pairs"

		xKeys = oDict.callMethod("keys")
		assert(xKeys != NULL, "PyDict.callMethod('keys') should return non-null")
		? "  keys: OK"

		oEmpty = new PyDict([])
		assert(oEmpty.len() = 0, "empty PyDict should have len 0")
		? "  empty len: " + oEmpty.len()
		? ""

	func testPyTupleClass
		? "--- OOP: PyTuple Class ---"

		oTuple = new PyTuple([1, 2, 3])

		cType = oTuple.type()
		assert(cType = "tuple", "PyTuple.type() should return 'tuple'")
		? "  type: " + cType

		nLen = oTuple.len()
		assert(nLen = 3, "PyTuple.len() should return 3")
		? "  len: " + nLen

		cStr = oTuple.str()
		assert(cStr = "(1, 2, 3)", "PyTuple.str() should return '(1, 2, 3)'")
		? "  str: " + cStr

		aVal = oTuple.value()
		assert(isList(aVal) and len(aVal) = 3, "PyTuple.value() should return Ring list of 3")
		? "  value: " + len(aVal) + " items"

		nCount = oTuple.callMethodArgs("count", [2])
		assert(nCount = 1, "PyTuple.callMethodArgs('count', [2]) should return 1")
		? "  count(2): " + nCount

		nIdx = oTuple.callMethodArgs("index", [3])
		assert(nIdx = 2, "PyTuple.callMethodArgs('index', [3]) should return 2")
		? "  index(3): " + nIdx

		oEmpty = new PyTuple([])
		assert(oEmpty.len() = 0, "empty PyTuple should have len 0")
		? "  empty len: " + oEmpty.len()
		? ""

	func testPyValueClass
		? "--- OOP: PyValue Class ---"

		oNum = new PyValue(42)
		assert(oNum.type() = "int", "PyValue(42).type() should return 'int'")
		assert(oNum.value() = 42, "PyValue(42).value() should return 42")
		? "  PyValue(42): type=" + oNum.type() + " value=" + oNum.value()

		oStr = new PyValue("hello")
		assert(oStr.type() = "str", "PyValue('hello').type() should return 'str'")
		assert(oStr.value() = "hello", "PyValue('hello').value() should return 'hello'")
		? "  PyValue('hello'): type=" + oStr.type() + " value=" + oStr.value()

		oFloat = new PyValue(3.14)
		assert(oFloat.type() = "float", "PyValue(3.14).type() should return 'float'")
		nVal = oFloat.value()
		assert(nVal > 3.13 and nVal < 3.15, "PyValue(3.14).value() should be ~3.14")
		? "  PyValue(3.14): type=" + oFloat.type() + " value=" + nVal

		oList = new PyValue([1, 2, 3])
		assert(oList.type() = "list", "PyValue([1,2,3]).type() should return 'list'")
		assert(oList.len() = 3, "PyValue([1,2,3]).len() should return 3")
		? "  PyValue([1,2,3]): type=" + oList.type() + " len=" + oList.len()
		? ""
