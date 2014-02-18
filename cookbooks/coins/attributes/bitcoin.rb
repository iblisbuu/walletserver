default[:coins][:bitcoin][:source] = 'https://bitcoin.org/bin/0.8.6/bitcoin-0.8.6-linux.tar.gz'
default[:coins][:bitcoin][:executable] = 'bitcoind'
default[:coins][:bitcoin][:rpc_user] = 'bitcoin'
default[:coins][:bitcoin][:rpc_pass] = 'bitcoind'
default[:coins][:bitcoin][:rpc_allow_net] = '127.0.0.1'
default[:coins][:bitcoin][:wallet_location] = 'S3'
default[:coins][:bitcoin][:wallet_s3_bucket] = ''
default[:coins][:bitcoin][:wallet_s3_user] = ''
default[:coins][:bitcoin][:wallet_s3_secret] = ''

