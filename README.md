# Welcome

fork project from [HashLips](https://github.com/HashLips/hashlips_art_engine)


# 如何发行nft到opensea

## 图片生成
**设计** 设计制作自己的原创素材，按照不同的分层元素给出原始素材图片   
**生成工具** 用工具生成随机不同的图片，工具可以参考hashlips。

注意：一定要用同时生成meta的工具。hashlips可以生成meta

什么是meta?    
 meta是nft的描述文件，比如图片地址，编号，属性等。对于opensea来说其实是读的这个meta显示对应的nft图片

## 上传到ipfs
制作好了1k张图片就需要上传到一个永久存储的地方，供nft获取。也就是说链上其实只是记录了一个图片地址，真正的图片是off chain的（不在链上的）。标准的做法是图片放到ipfs（ipfs是一个分布式存储网络，也是基于链的），常用的ipfs存储网站有pinata，nft.storage等。

**坑** 这里有个坑，在操作的时候发现10k图片有3G，根本就传不上去，太慢了。并且对应pinata来说，免费版只有1G，空间不够，需要购买付费版。  
所以这里怎么解决呢？  
图片上传阿里云oss，好处是传得快，几分钟就搞定，费用很便宜。
meta文件（json格式），传到ipfs，可以去pinata上传

## 制作合约

接下来要做的是把nft放到链上，标准的做法是创建合约，把信息写到链上。有人会问，不是要放到opensea上去卖吗？

这里简单解释下openea，opensea其实是个二级市场，是在你钱包里面的资产可以在opensea上卖，所以其实第一步不是去上传opensea，第一步是放到自己的钱包里面，只不过opensea也提供了直接上传售卖的方式，所以理解起来有点晕，其实他是个二级市场。

我们这次要做的就是先挖到自己钱包了，然后再去opensea出售。当你钱包里面有了nft，opensea登录后你会看到也已经有了，这就是去中心化世界的好处，你的资产就在钱包里，只要授权就可以读到钱包里面的资产。不需要中心化的账号。


### 合约代码
参考库里面smart_contract代码，我们项目之前使用的代码。具备如下功能：
1. devmint ，空投（免费）
1. 白名单（支持设置白名单，只有白名单用户可挖）
1. 公开发售
1. 支持修改各个阶段的价格

### 部署合约
这块有很多工具，还是觉得remix比较简单，可以去[remix](https://remix.ethereum.org/)网站操作，具体部署可以进群交流

部署后就可以devmint调用接口挖了。然后去opeasea看看自己账号下应该就会出现挖到的nft

![](https://github.com/mboo2005/hashlips_art_engine/blob/main/group.jpeg)
