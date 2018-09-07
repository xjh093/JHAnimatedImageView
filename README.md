# JHAnimatedImageView
A subclass of UIImageView for animation with High Performance

---

# Test

- size:750x1334 
- count:44
- Simulator: iPhone 8
- times：5

Launch 
- Memory - CPU
- 46.4% - 2%

|times |KKSequenceImageView | YYAnimatedImageView | JHAnimatedImageView | UIImageView
|-|-|-|-|-|
| | Memory - CPU | Memory - CPU | Memory - CPU | Memory - CPU
|1 |50.9M  - 21% | 47.3M  - 36% | 47.2M  - 22% | 216M - 132%
|2 |54.7M  - 19% | 47.4M  - 47% | 47.3M  - 23% | 216M - 2%
|3 |54.8M  - 19% | 47.3M  - 58% | 47.3M  - 22% | 216M - 1%
|4 |54.8M  - 20% | 48.9M  - 44% | 51.1M  - 22% | 216M - 1%
|5 |54.8M  - 19% | 47.4M  - 49% | 47.4M  - 22% | 216M - 0%

---

# Performance comparison

## Launch
![image](https://github.com/xjh093/JHAnimatedImageView/blob/master/images/Launch.gif)

## UIImageView
![image](https://github.com/xjh093/JHAnimatedImageView/blob/master/images/UIImageView.gif)

## KKSequenceImageView
![image](https://github.com/xjh093/JHAnimatedImageView/blob/master/images/KKSequenceImageView.gif)

## YYAnimatedImageView
![image](https://github.com/xjh093/JHAnimatedImageView/blob/master/images/YYAnimatedImageView.gif)

## JHAnimatedImageView
![image](https://github.com/xjh093/JHAnimatedImageView/blob/master/images/JHAnimatedImageView.gif)

---


