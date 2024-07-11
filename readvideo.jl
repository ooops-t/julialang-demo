using Images
using ColorTypes
using VideoIO
using GLMakie

videoreader = VideoIO.openvideo("video.hevc")

function convert_to_yuv420(rgb)
	w, h = size(rgb)[1:2]
	yuv420 = zeros(Float32, 6, floor(Int64, w / 2), floor(Int64, h / 2))

	yuv_img = convert.(YCbCr, rgb)

	y = channelview(yuv_img)[1, :, :]
	u = channelview(yuv_img)[2, :, :]
	v = channelview(yuv_img)[3, :, :]
	
	yuv420[1, :, :] = y[1:2:end, 1:2:end]
	yuv420[2, :, :] = y[1:2:end, 2:2:end]
	yuv420[3, :, :] = y[2:2:end, 1:2:end]
	yuv420[4, :, :] = y[2:2:end, 2:2:end]
	yuv420[5, :, :] = imresize(u, floor(Int64, w / 2), floor(Int64, h / 2))
	yuv420[6, :, :] = imresize(v, floor(Int64, w / 2), floor(Int64, h / 2))

	return yuv420
end

W = 256
H = 512

img = VideoIO.read(videoreader)
img = Images.imresize(img, W, H)
yuv420 = convert_to_yuv420(img)

fig, ax, plot_obj = image(img', interpolate=false, axis=(yreversed=true, ))
display(fig)

while !eof(videoreader)
	nimg = VideoIO.read(videoreader)
	nimg = Images.imresize(nimg, W, H)
	nyuv420 = convert_to_yuv420(nimg)
	plot_obj[1] = nimg'
	sleep(0.05)
end
