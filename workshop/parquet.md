```
$ pip install pyarrow

import pyarrow as pa
from pyarrow import csv
import pandas as pd

cvs_header = [
    'CODE',
    'SRMB',
    'N_CODE',
    'T_CODE',
    'NAME',
    'RC_DATE',
    'STTG_DATE',
    'END_DATE',
    'RC_CDTN_CODE',
    'CTRC_NUM',
    'BUY_GB',
    'DVSN_CODE',
    'YSNO',
    'CDTN_CODE',
    'SOURCE_NM',
    'PRO_DATE_DATE'
]

def convertToParquet(filename, output) :
    convert_opts = csv.ConvertOptions(column_types =
                        {
                            'CTRC_DATE': pa.date32(),
                            'CTRC_STTG_DATE': pa.date32(),
                            'CTRC_END_DATE': pa.date32(),
                            'PRO_DATE_DATE': pa.date32()
                        }
                   )

    table = csv.read_csv(filename,
                 convert_options=convert_opts,
                 read_options=csv.ReadOptions(column_names=cvs_header, autogenerate_column_names=True),
                 parse_options=csv.ParseOptions(delimiter='|'))

    """
    print(type(table))
    print(table.column_names)
    print(table.schema)
    """
    print(table.schema)

    df = table.to_pandas()
    """
    print(df.head())
    print(df.shape)
    print(type(df))
    print(df.info())
    """
    df.to_parquet(output, engine='pyarrow', index=False)


def readParquet(filename) :
    df = pd.read_parquet(filename, engine="pyarrow")
    print(df.info())
    print(df.head())


convertToParquet("input.csv", "output.parquet")
readParquet("output.parquet")


```

## 참고자료 ##

* [아파치 arrow 사용법](https://yahwang.github.io/posts/83)

* https://stackoverflow.com/questions/42786398/how-to-query-parquet-data-from-amazon-athena
