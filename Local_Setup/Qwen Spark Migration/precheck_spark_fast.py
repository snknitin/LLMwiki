"""One explicitly requested, 16-token, non-thinking SparkFast responsiveness check."""
import datetime
import json
from pathlib import Path
from continue_native_reviewed import spark_fast_responsiveness

if __name__ == '__main__':
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    output = Path('/home/snknitin/runs/qwen38-native') / ('spark-fast-precheck-' + stamp + '.json')
    result = spark_fast_responsiveness(output)
    print(json.dumps({'receipt': str(output), **result}))
