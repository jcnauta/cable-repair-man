extends Node

func sort_by_first(e0, e1):
    return e0[0] < e1[0]

func only_second_elements(arr):
    var new_arr = []
    for e in arr:
        new_arr.append(e[1])
    return new_arr

# report whether two arrays contain elements that are equal
# (but possibly in different order)
func elements_equal(arr0, arr1):
    if len(arr0) != len(arr1):
        return false
    else:
        var arr0b = arr0.duplicate()
        var arr1b = arr1.duplicate()
        while len(arr0b) > 0:
            var e0 = arr0b.pop_back()
            var idx1 = 0
            var matched = false
            while idx1 < len(arr1b):
                if e0 == arr1b[idx1]:
                    arr1b.remove(idx1)
                    matched = true
                    break
                idx1 += 1
            if not matched:
                return false
        return true
