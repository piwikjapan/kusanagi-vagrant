# kusanagi-vagrant

# 概要
kusanagi VM （virtual machine）環境を Vagrant/VirtualBox で [bento/centos-7.6](https://app.vagrantup.com/bento/boxes/centos-7.6) 
から作り上げます。

## [KUSANAGI for Vagrant](https://kusanagi.tokyo/cloud/kusanagi-for-vagrant/) との違い

[KUSANAGI for Vagrant](https://kusanagi.tokyo/cloud/kusanagi-for-vagrant/) は、予め全てがインストールされたイメージを
ダウンロードするのに対し、本レポジトリ kusanagi-vagrant は、[bento/centos-7.6](https://app.vagrantup.com/bento/boxes/centos-7.6) 
に必要パッケージをスクリプトでインストールします。
 
## 検証環境

* Ubuntu 18.04 LTS
* kusanagi Version 8.4.2-2
* Windows 環境下では未検証です

# Vagrant/VirtualBox のインストール

[Vagrant+VirtualBoxでUbuntu環境構築](https://qiita.com/w2-yamaguchi/items/191830191f8af05ac4dd) などを参照して
VirtualBox 以下で Vagrant が立ち上がるようにしておいてください。
* 本レポジトリ kusanagi-vagrant は Windows 環境下では未検証です

## Vagrant plugins

実行時に必要な Vagrant plugin をインストールします。
```
$ vagrant plugin install vagrant-proxyconf vagrant-disksize vagrant-vbguest dotenv
```

proxy 使用時は環境変数に proxy サーバーを設定しておきます。例えば proxy サーバーのアドレスが http://192.168.1.1:3128 のときは:
```
$ export http_proxy=http://192.168.1.1:3128
$ export https_proxy=http://192.168.1.1:3128
```
* プラグインをインストール後、proxy サーバーのアドレスは .env ファイルに設定します。

# kusanagi VM 環境構築

```
$ git clone git@github.com:piwikjapan/kusanagi-vagrant.git
$ cd kusanagi-vagrant
```

## proxy の設定

.env で http / https proxy を設定します。

* .env の例:<br/>
proxy が http://192.168.1.1:3128 にある
```
http_proxy="http://192.168.1.1:3128"
https_proxy="http://192.168.1.1:3128"
```
* proxy がないとき
```
http_proxy=""
https_proxy=""
```
## vagrant up （一度目）

* bento/centos OS のアップデート
* 各種レポジトリの設定
* 必要パッケージのインストール
* 必要な一般ユーザーとグループの作成
* mysql_secure_installation の実行
* mysql の root パスワードは kusanagi です

最後に次のメッセージが出れば終了です:

```
$ vagrant up
Proxy Settings:
 http.proxy http://192.168.1.1:3128
 https.proxy http://192.168.1.1:3128
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Box 'bento/centos-7.6' could not be found. Attempting to find and install...

-- 略 --

default: Reload privilege tables now? [Y/n]
default: ------------------------------------------------------------------------
default: Initial database password is "kusanagi".
default: Provisioning is over. Power off. Execute "vagrant up" command again.
default: ------------------------------------------------------------------------
$
```

新しいカーネルがインストールされるので、poweroff コマンドでいったんシャットダウンします。再び vagurant up を
実行すると新しくインストールされたカーネルで CentOS が立ち上がります。


### 途中でとまるとき

#### 必要プラグインのインストール

vagrant の必要プラグインのインストール指示がでましたら、指示通り実行してください。次のメッセージで止まれば:

```
vagrant-proxyconf is not installed ("vagrant plugin install vagrant-proxyconf")
```
vagrant プラグインをインストールし vagrant up で続行します:
```
$ vagrant plugin install vagrant-proxyconf
-- 略 --
$ vagrant up
```

#### レポジトリの応答がタイムアウト

レポジトリの応答がタイムアウトになるときがたまにあります。以下は remi-php56 のインストール時にレポジトリ
から応答遅延してタイムアウトになった例です:

```
    default: Cannot find a valid baseurl for repo: remi-php56
The SSH command responded with a non-zero exit status. Vagrant
assumes that this means the command failed. The output for this command
should be in the log above. Please read the output to determine what
went wrong.
```

とまるたびに以下を実行してください。 Provisioning is over. まで、何度実行してもいいです:
```
$ vagrant halt
Proxy Settings:
 http.proxy http://192.168.1.1:3128
 https.proxy http://192.168.1.1:3128
$ vagrant on --provision
```

### インストール途中で libjpeg.so.62 がないといわれる

libjpeg.so.62 がないと途中怒られるのですが:
```
default: g_module_open() failed for /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-jasper.so: libjpeg.so.62: cannot open shared object file: No such file or directory
default: g_module_open() failed for /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-jpeg.so: libjpeg.so.62: cannot open shared object file: No such file or directory
default: g_module_open() failed for /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-tiff.so: libjpeg.so.62: cannot open shared object file: No such file or directory
```

vagrant up （二度目）が終われば libjpeg.so.62 は見えているので大丈夫だとは思います:

```
[vagrant@kusanagi-dev ~]$ ldd /usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-jasper.so
        linux-vdso.so.1 =>  (0x00007ffd50fcc000)
        libjasper.so.1 => /lib64/libjasper.so.1 (0x00007ffbeed33000)
        libgdk_pixbuf-2.0.so.0 => /lib64/libgdk_pixbuf-2.0.so.0 (0x00007ffbeeb0b000)
        libgmodule-2.0.so.0 => /lib64/libgmodule-2.0.so.0 (0x00007ffbee907000)
        libgio-2.0.so.0 => /lib64/libgio-2.0.so.0 (0x00007ffbee568000)
        libgobject-2.0.so.0 => /lib64/libgobject-2.0.so.0 (0x00007ffbee318000)
        libglib-2.0.so.0 => /lib64/libglib-2.0.so.0 (0x00007ffbee002000)
        libpng15.so.15 => /lib64/libpng15.so.15 (0x00007ffbeddd7000)
        libm.so.6 => /lib64/libm.so.6 (0x00007ffbedad5000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00007ffbed8b9000)
        libc.so.6 => /lib64/libc.so.6 (0x00007ffbed4ec000)
        libjpeg.so.62 => /usr/local/lib/libjpeg.so.62 (0x00007ffbed25c000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00007ffbed058000)
        libpcre.so.1 => /lib64/libpcre.so.1 (0x00007ffbecdf6000)
        libffi.so.6 => /lib64/libffi.so.6 (0x00007ffbecbee000)
        libz.so.1 => /lib64/libz.so.1 (0x00007ffbec9d8000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00007ffbec7b1000)
        libresolv.so.2 => /lib64/libresolv.so.2 (0x00007ffbec598000)
        libmount.so.1 => /lib64/libmount.so.1 (0x00007ffbec355000)
        libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00007ffbec13f000)
        /lib64/ld-linux-x86-64.so.2 (0x00007ffbef190000)
        libblkid.so.1 => /lib64/libblkid.so.1 (0x00007ffbebeff000)
        libuuid.so.1 => /lib64/libuuid.so.1 (0x00007ffbebcfa000)
```

libjpeg.so.62  もともと libjpeg-turbo に存在しますが、kusanagi-mozjpeg で置き換えられます。

## vagrant up （二度目）

* 更新されたカーネルで起動
* VirtualBox GuestAdditions のアップデート

```
$ vagrant up
Proxy Settings:
 http.proxy http://192.168.1.1:3128
 https.proxy http://192.168.1.1:3128
Bringing machine 'default' up with 'virtualbox' provider...
-- 略 --
    default: 80 (guest) => 10080 (host) (adapter 1)
    default: 443 (guest) => 10443 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
-- 略 --
[default] GuestAdditions 5.2.26 running --- OK.
-- 略 --
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> default: flag to force provisioning. Provisioners marked to run always will still run.
$
```

vagrant up （一度目）の yum によるカーネルアップデートと GuestAdditions のアップデートを同時に行うと
ハングアップしてしてしまう場合があるので二度にわけました。

## kusanagi init

vagrant up （二度目）で VM があがってきたら、 kusanagi 初期化を実行します。 いろいろ質問してきますが内容については
 [KUSANAGIの初期設定](https://kusanagi.tokyo/document/command/#init) を参照してください:

```
$ vagrant ssh

     __ ____  _______ ___    _   _____   __________
    / //_/ / / / ___//   |  / | / /   | / ____/  _/
   / ,< / / / /\__ \/ /| | /  |/ / /| |/ / __ / /
  / /| / /_/ /___/ / ___ |/ /|  / ___ / /_/ // /
 /_/ |_\____//____/_/  |_/_/ |_/_/  |_\____/___/

    Version 8.4.2-2, Powered by Prime Strategy.

[vagrant@kusanagi-dev ~]$ sudo kusanagi init

KUSANAGIのバージョンをチェックしています。
KUSANAGIの最新バージョンをご使用いただき、ありがとうございます。
セキュリティ向上のため、2048ビット DHE鍵を生成します。
-- 略 --
Mroongaをインストールしますか ?: [y/N]n
Removed symlink /etc/systemd/system/multi-user.target.wants/mariadb.service.
Removed symlink /etc/systemd/system/mysql.service.
Removed symlink /etc/systemd/system/mysqld.service.
innodb_buffer_pool_size = 768M
query_cache_size = 192M
Created symlink from /etc/systemd/system/mysql.service to /usr/lib/systemd/system/mariadb.service.
Created symlink from /etc/systemd/system/mysqld.service to /usr/lib/systemd/system/mariadb.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
MariaDBを再起動します
hhvm を使用します
NOTICE: Please run the following command to change the php command path in the current shell.

$ hash -r

monitはすでに起動されています。何もしません

KUSANAGIの初期設定を完了しました。
完了しました。
[vagrant@kusanagi-dev ~]$
```

### Mroonga のインストールについて

kusanagi init 時の最後の質問 Mroongaをインストールしますか ? は n と答えてください。y だと kusanagi init
が失敗します:

```
Mroongaをインストールしますか ?: [y/N]y
/usr/lib/kusanagi/lib/functions.sh: line 866: install_mroonga: command not found
Mroongaのインストールが失敗しました。
```

Mroonga が必要であれば別途 add-on としてインストールします。

```
[vagrant@kusanagi-dev ~]$ sudo kusanagi status | grep -1 add-on

*** add-on ***

[vagrant@kusanagi-dev ~]$ sudo kusanagi addon install mroonga
Loaded plugins: fastestmirror
groonga-release-1.3.0-1.noarch.rpm
-- 略 --
INFO: add-on install was successful
完了しました。
[vagrant@kusanagi-dev ~]$ sudo kusanagi status | grep -1 add-on

*** add-on ***
(active) Mroonga
```


# kusanagi VM の操作

## VM へログイン

Virtualbox を動かしているホスト（以下母艦といいます）で:
```
$ vagrant ssh
Proxy Settings:
 http.proxy http://192.168.1.1:3128
 https.proxy http://192.168.1.1:3128
Last login: Wed Mar 13 01:48:22 2019 from 192.168.1.200

     __ ____  _______ ___    _   _____   __________
    / //_/ / / / ___//   |  / | / /   | / ____/  _/
   / ,< / / / /\__ \/ /| | /  |/ / /| |/ / __ / /
  / /| / /_/ /___/ / ___ |/ /|  / ___ / /_/ // /
 /_/ |_\____//____/_/  |_/_/ |_/_/  |_\____/___/

    Version 8.4.2-2, Powered by Prime Strategy.

[vagrant@kusanagi-dev ~]$
```
## VM をシャットダウン

母艦で:
```
$ vagrant halt
```

## VM をきれいさっぱり消す

母艦で:
```
$ vagrant destory
```


# ポートマッピング

## ssh
母艦の 2222 に紐づけられています。
*  VM 中の .ssh/authorized_keys に公開鍵を設定すれば母艦からログイン可能です:
```
$ ssh vagrant@localhost -p 2222
```

## http

母艦の 10080 に紐づけられています。
* Vagrantfile で変更可能です。 ただし、母艦の 80 ポートには紐づけるには vagrant を root 権限で
実行しなければなりません。
* iptable を使えば母艦の 80 ポートを同じく母艦の 10080 に転送できます。<br/>
ただし、ローカルホスト（127.0.0.1）には使えません:
```
$ sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 10080
```

## https

母艦の 10443 に紐づけられています。
* Vagrantfile で変更可能です。 ただし、母艦の 443 ポートには紐づけるには vagrant を root 権限で
実行しなければなりません。
* iptable を使えば母艦の 443 ポートを同じく母艦の 10443 に転送できます。<br/>
ただし、ローカルホスト（127.0.0.1）には使えません:
```
$ sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 10443
```
