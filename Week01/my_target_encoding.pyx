# distutils: language=c++
import numpy as np
cimport numpy as np
import pandas as pd


def target_mean_v1(data, y_name, x_name):
    result = np.zeros(data.shape[0])
    for i in range(data.shape[0]):
        groupby_result = data[data.index != i].groupby([x_name], as_index=False).agg(['mean', 'count'])
        result[i] = groupby_result.loc[groupby_result.index == data.loc[i, x_name], (y_name, 'mean')]
    return result


def target_mean_v2(data, y_name, x_name):
    datashape = data.shape[0]
    result = np.zeros(datashape)
    value_dict = dict()
    count_dict = dict()
    for i in range(datashape):
        if data[i][ x_name] not in value_dict.keys():
            value_dict[data[i][ x_name]] = data[i][y_name]
            count_dict[data[i][ x_name]] = 1
        else:
            value_dict[data[i][ x_name]] += data[i][y_name]
            count_dict[data[i][ x_name]] += 1
    for i in range(datashape):
        result[i] = (value_dict[data[i][ x_name]] - data[i][y_name]) / (count_dict[data[i][ x_name]] - 1)
    return result



def main():
    y = np.random.randint(2, size=(5000, 1))
    x = np.random.randint(10, size=(5000, 1))
    matrix = np.concatenate((y,x),axis = 1)
    data = pd.DataFrame(np.concatenate([y, x], axis=1), columns=['y', 'x'])
    cdef np.ndarray[double, ndim=2, mode='c'] arg = np.asfortranarray(matrix, dtype=np.float64)
    result_1 = target_mean_v1(data, 'y', 'x')
    result_2 = target_mean_v2(data, 0, 1)

    diff = np.linalg.norm(result_1 - result_2)
    print(diff)


if __name__ == '__main__':
    main()