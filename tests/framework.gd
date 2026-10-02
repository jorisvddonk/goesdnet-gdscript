class_name GoTestContext
extends RefCounted

var suite := ""
var passed := 0
var failed := 0
var failures: Array[String] = []


func check(cond: bool, label: String) -> void:
	if cond:
		passed += 1
	else:
		failed += 1
		failures.append(label)


func eq(actual, expected, label: String) -> void:
	if actual == expected:
		passed += 1
	else:
		failed += 1
		failures.append(label + " (expected " + str(expected) + ", got " + str(actual) + ")")
