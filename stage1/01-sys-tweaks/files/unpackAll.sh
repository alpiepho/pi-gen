# EXTENDED - example of unpacking and building tools
#
# git hash list:
# mbpoll-clone -  0e39610a447f815813332c73dcd40914a108f0f2
#
# unpack all uninstalled tgz files
cd /home/pi

tar xzvf mbpoll-clone.tgz
mkdir mbpoll-clone/build
cd mbpoll-clone/build
cmake ..
make
sudo make install
cd -


