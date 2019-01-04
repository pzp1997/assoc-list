var pzp1997$assoc_list$AssocList$D = elm$core$Basics$identity;

var pzp1997$assoc_list$AssocList$empty = _List_Nil;

var pzp1997$assoc_list$AssocList$get = F2(
	function (targetKey, _n0) {
		get:
		while (true) {
			var alist = _n0;
			if (!alist.b) {
				return elm$core$Maybe$Nothing;
			} else {
				var _n2 = alist.a;
				var key = _n2.a;
				var value = _n2.b;
				var rest = alist.b;
				if (_Utils_eq(key, targetKey)) {
					return elm$core$Maybe$Just(value);
				} else {
					var $temp$targetKey = targetKey,
						$temp$_n0 = rest;
					targetKey = $temp$targetKey;
					_n0 = $temp$_n0;
					continue get;
				}
			}
		}
	});

var pzp1997$assoc_list$AssocList$member = F2(
	function (targetKey, dict) {
		var _n0 = A2(pzp1997$assoc_list$AssocList$get, targetKey, dict);
		if (!_n0.$) {
			return true;
		} else {
			return false;
		}
	});

var pzp1997$assoc_list$AssocList$size = function (_n0) {
	var alist = _n0;
	return elm$core$List$length(alist);
};

var pzp1997$assoc_list$AssocList$isEmpty = function (dict) {
	return _Utils_eq(dict, _List_Nil);
};

var pzp1997$assoc_list$AssocList$eq = F2(
	function (leftDict, rightDict) {
		return A6(
			pzp1997$assoc_list$AssocList$merge,
			F3(
				function (_n0, _n1, _n2) {
					return false;
				}),
			F4(
				function (_n3, a, b, result) {
					return result && _Utils_eq(a, b);
				}),
			F3(
				function (_n4, _n5, _n6) {
					return false;
				}),
			leftDict,
			rightDict,
			true);
	});

var pzp1997$assoc_list$AssocList$insert = F3(
	function (key, value, dict) {
		var _n0 = A2(pzp1997$assoc_list$AssocList$remove, key, dict);
		var alteredAlist = _n0;
		return A2(
			elm$core$List$cons,
			_Utils_Tuple2(key, value),
			alteredAlist);
	});

var pzp1997$assoc_list$AssocList$remove = F2(
	function (targetKey, _n0) {
		var alist = _n0;
		return A2(
			elm$core$List$filter,
			function (_n1) {
				var key = _n1.a;
				return !_Utils_eq(key, targetKey);
			},
			alist);
	});

var pzp1997$assoc_list$AssocList$update = F3(
	function (targetKey, alter, dict) {
		var alist = dict;
		var maybeValue = A2(pzp1997$assoc_list$AssocList$get, targetKey, dict);
		if (!maybeValue.$) {
			var _n1 = alter(maybeValue);
			if (!_n1.$) {
				var alteredValue = _n1.a;
				return A2(
					elm$core$List$map,
					function (entry) {
						var key = entry.a;
						return _Utils_eq(key, targetKey) ? _Utils_Tuple2(targetKey, alteredValue) : entry;
					},
					alist);
			} else {
				return A2(pzp1997$assoc_list$AssocList$remove, targetKey, dict);
			}
		} else {
			var _n2 = alter(elm$core$Maybe$Nothing);
			if (!_n2.$) {
				var alteredValue = _n2.a;
				return A2(
					elm$core$List$cons,
					_Utils_Tuple2(targetKey, alteredValue),
					alist);
			} else {
				return dict;
			}
		}
	});

var pzp1997$assoc_list$AssocList$singleton = F2(
	function (key, value) {
		return _List_fromArray(
			[
				_Utils_Tuple2(key, value)
			]);
	});

var pzp1997$assoc_list$AssocList$union = F2(
	function (_n0, rightDict) {
		var leftAlist = _n0;
		return A3(
			elm$core$List$foldr,
			F2(
				function (_n1, result) {
					var lKey = _n1.a;
					var lValue = _n1.b;
					return A3(pzp1997$assoc_list$AssocList$insert, lKey, lValue, result);
				}),
			rightDict,
			leftAlist);
	});

var pzp1997$assoc_list$AssocList$intersect = F2(
	function (_n0, rightDict) {
		var leftAlist = _n0;
		return A2(
			elm$core$List$filter,
			function (_n1) {
				var key = _n1.a;
				return A2(pzp1997$assoc_list$AssocList$member, key, rightDict);
			},
			leftAlist);
	});

var pzp1997$assoc_list$AssocList$diff = F2(
	function (_n0, rightDict) {
		var leftAlist = _n0;
		return A2(
			elm$core$List$filter,
			function (_n1) {
				var key = _n1.a;
				return !A2(pzp1997$assoc_list$AssocList$member, key, rightDict);
			},
			leftAlist);
	});

var pzp1997$assoc_list$AssocList$merge = F6(
	function (leftStep, bothStep, rightStep, leftDict, _n0, initialResult) {
		var leftAlist = leftDict;
		var rightAlist = _n0;
		var _n1 = A2(
			elm$core$List$partition,
			function (_n2) {
				var key = _n2.a;
				return A2(pzp1997$assoc_list$AssocList$member, key, leftDict);
			},
			rightAlist);
		var inBothAlist = _n1.a;
		var inRightOnlyAlist = _n1.b;
		var intermediateResult = A3(
			elm$core$List$foldr,
			F2(
				function (_n5, result) {
					var rKey = _n5.a;
					var rValue = _n5.b;
					return A3(rightStep, rKey, rValue, result);
				}),
			initialResult,
			inRightOnlyAlist);
		return A3(
			elm$core$List$foldr,
			F2(
				function (_n3, result) {
					var lKey = _n3.a;
					var lValue = _n3.b;
					var _n4 = A2(pzp1997$assoc_list$AssocList$get, lKey, inBothAlist);
					if (!_n4.$) {
						var rValue = _n4.a;
						return A4(bothStep, lKey, lValue, rValue, result);
					} else {
						return A3(leftStep, lKey, lValue, result);
					}
				}),
			intermediateResult,
			leftAlist);
	});

var pzp1997$assoc_list$AssocList$map = F2(
	function (alter, _n0) {
		var alist = _n0;
		return A2(
			elm$core$List$map,
			function (_n1) {
				var key = _n1.a;
				var value = _n1.b;
				return _Utils_Tuple2(
					key,
					A2(alter, key, value));
			},
			alist);
	});

var pzp1997$assoc_list$AssocList$foldl = F3(
	function (func, initialResult, _n0) {
		var alist = _n0;
		return A3(
			elm$core$List$foldl,
			F2(
				function (_n1, result) {
					var key = _n1.a;
					var value = _n1.b;
					return A3(func, key, value, result);
				}),
			initialResult,
			alist);
	});

var pzp1997$assoc_list$AssocList$foldr = F3(
	function (func, initialResult, _n0) {
		var alist = _n0;
		return A3(
			elm$core$List$foldr,
			F2(
				function (_n1, result) {
					var key = _n1.a;
					var value = _n1.b;
					return A3(func, key, value, result);
				}),
			initialResult,
			alist);
	});

var pzp1997$assoc_list$AssocList$filter = F2(
	function (isGood, _n0) {
		var alist = _n0;
		return A2(
			elm$core$List$filter,
			function (_n1) {
				var key = _n1.a;
				var value = _n1.b;
				return A2(isGood, key, value);
			},
			alist);
	});

var pzp1997$assoc_list$AssocList$partition = F2(
	function (isGood, _n0) {
		var alist = _n0;
		var _n1 = A2(
			elm$core$List$partition,
			function (_n2) {
				var key = _n2.a;
				var value = _n2.b;
				return A2(isGood, key, value);
			},
			alist);
		var good = _n1.a;
		var bad = _n1.b;
		return _Utils_Tuple2(good, bad);
	});

var pzp1997$assoc_list$AssocList$keys = function (_n0) {
	var alist = _n0;
	return A2(elm$core$List$map, elm$core$Tuple$first, alist);
};

var pzp1997$assoc_list$AssocList$values = function (_n0) {
	var alist = _n0;
	return A2(elm$core$List$map, elm$core$Tuple$second, alist);
};

var pzp1997$assoc_list$AssocList$toList = function (_n0) {
	var alist = _n0;
	return alist;
};

var pzp1997$assoc_list$AssocList$fromList = function (alist) {
	return A3(
		elm$core$List$foldl,
		F2(
			function (_n0, result) {
				var key = _n0.a;
				var value = _n0.b;
				return A3(pzp1997$assoc_list$AssocList$insert, key, value, result);
			}),
		_List_Nil,
		alist);
};
