---
title: "[Discrete Fourier Transform] by Hand ✍️"
author: "Tom Yeh"
username: "@ProfTomYeh"
date: "2024-06-25"
tweet_url: "https://x.com/ProfTomYeh/status/1805694219031662799"
tweet_type: "original"
likes: 1312
retweets: 243
replies: 12
bookmarks: 921
views: 116636
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# [Discrete Fourier Transform] by Hand ✍️

> **Source:** [@ProfTomYeh](https://x.com/ProfTomYeh) · 2024-06-25 · 👍 1312 · 💬 12 · 🔖 921 · 👁 116636

> 🔗 [View tweet on X](https://x.com/ProfTomYeh/status/1805694219031662799)

## Tweet Content

[Discrete Fourier Transform] by Hand 

In signal processing, the Discrete Fourier Transform (DFT) is no doubt the most important method. But the math involved is extremely complex, literally, involving a summation over a complex number term e^(-iwt).

I developed this exercise to demonstrate that underneath such complexity, DFT is just a series of matrix multiplications you can calculate by hand.  

Once you see that, it should not surprise you that a deep neural network, which is also a series of matrix multiplications, with activation functions in-between, can learn to perform DFT to process and analyze signals so effectively.

How does DFT work?

[1] Given
â†³ Signals A, B, and C in the  frequency domain:
â—¦ A = cos(w) + 2cos(2w)
â—¦ B = cos(w) + cos(3w) + cos(4w)
â—¦ C = -cos(2w) + cos(3w)
â—¦ Each signal is a weighed sum of four cosine waves at frequencies 1w, 2w, 3w, and 4w.
â—¦ We will apply Inverse DFT to convert the signals to time domain representations, and then demonstrate DFT can convert back to their original frequency domain representations.
â†³ Signal X in the  time domain. X is sampled at 10 time points 1t, 2t, â€¦, 10t:
â—¦ X = [-2.5, -1.8, 3, -0.7, -1.0, -0.7, 3, -1.8, -2.5, 5]
â—¦ Suppose X is also a weighted sum of the same four cosine waves, but we donâ€™t already know their weights. We will apply DFT to discover them.

[2]  Frequency Matrix (F)
â†³ Write the coefficients of A, B, C as a matrix F. Each signal is a row. Each frequency is a column.
â†³ A â†’ [1, 2, 0, 0]
â†³ B â†’ [1, 0, 1, 1]
â†³ C â†’ [0, 1-, 1, 0]

[3] Cosine â†’ Discrete
â†³ Sample from the continuous cosine waves at discrete time points 1t, 2t, 3t, to 10t.

[4] Cosine Matrix (W)
â†³ Write the samples as a matrix, Each frequency is a row. Each time point is a column.

[5] Inverse DFT:  Frequency â†’  Time
â†³ Multiply the frequency matrix F and the cosine matrix W.
â†³ The meaning of this multiplication is to linearly combine the four cosine waves (rows in W) into time-domain signals (rows in T) using the weights specified in F.
â†³ The result is matrix T, which are signals A, B, C converted to the time domain. Each signal is a row. Each time point is a column.

[6] Transpose
â†³ Transpose T, converting each signalâ€™s time domain representation from a row to a column.

[7] DFT:  Time â†’  Frequency
â†³ Multiply the cosine matrix W with the transpose of matrix T.
â†³ The purpose of this multiplication is to take a dot-product between each time-domain signal (columns in the transpose of T) and each cosine wave (rows in W), which has the effect of projecting the signal onto a cosine wave to determine how much they are correlated. Zero means not correlated at all.
â†³ The result is an intermediate version of the â€œrecoveredâ€ frequency matrix where each column corresponds to a signal and each row corresponds to a frequency.
â†³ Compared to the original frequency matrix F, this intermediate matrix has non-zero weights in the correct places, but scaled up by a factor of 5 (n/2, n=10). For example, signal A, originally [1,2,0,0], is recovered at [5,10,0,0].

[8] Scale
â†³ Multiply each value by 2/n = 1/5 to scale down the intermediate matrix to match the magnitude of the original frequency matrix F.

[9] Transpose
â†³ Transpose the recovered frequency matrix back to the same orientation of the original frequency matrix F.
â†³ Like magic , the result is identical to the original F, which means DFT successfully recovered the frequency components of signals A, B, C.

[10] Apply DFT to X:  Time â†’  Frequency
â†³ Now that we have some confidence in DFTâ€™s ability to recover frequency components, we apply DFT to Xâ€™s time-domain representation by multiplying W with X.
â†³ The result is the an intermediate matrix.

[11] Scale
â†³ Similarly, we scale down by a factor of 5 to obtain the recovered frequency components of X (a column).

[12] Transpose
â†³ Similarly, we transpose the recovered column to row to match the orientation of the frequency matrix.
â†³ Using the coefficients [0,0,3,2], we can write the equation of X as 3cos(3w) + 2cos(4w).

Notes:

I hope this by hand exercise helps you understand the essence of DFT. But there is more technical details, such as:

â€¢ Sine: The complete DFT math also includes sine waves that follow a similar calculation process.

â€¢ Phase: Here, we assume all the cosine waves are aligned at the origin, namely, phase is 0. If a phase p is added, for example, cos(w+p), we will need to calculate the sine component and use their ratio to figure out what p is.

â€¢ Magnitude: If phase is not zero, the magnitude will need to be calculated by combining both cosine and sine terms.

## Media

![Video thumbnail](https://pbs.twimg.com/ext_tw_video_thumb/1805693963464327168/pu/img/kOcpELm1j7wfqJlR.jpg)

**Video:** [▶ Watch](https://video.twimg.com/ext_tw_video/1805693963464327168/pu/vid/avc1/720x720/sjo9weCSDG0wSbIp.mp4?tag=12) (duration: 12s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

