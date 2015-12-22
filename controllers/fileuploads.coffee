module.exports = (app) ->
    multer  = require('multer')
    crypto = require('crypto')
    mime = require('mime')
    storage = multer.diskStorage(
        destination: (req, file, cb) ->
            cb(null, 'upload/')
        filename: (req, file, cb) ->
            crypto.pseudoRandomBytes(16, (err, raw) ->
                return cb(err) if (err)
#                cb(null, raw.toString('hex') + path.extname(file.originalname))
                cb(null, raw.toString('hex') + Date.now() + '.' + mime.extension(file.mimetype))
            )
    )

    upload = multer(
        storage: storage
    )


    app.get('/fileuploads', (req, res) ->
        res.render 'fileuploads_index',
            title: 'Upload a file'
            activeMenuItem: '/fileuploads'
    )

    app.post('/fileuploads', upload.single('file'), (req, res) ->
#        res.redirect('/fileuploads')
        console.log(req.files)
        res.render 'fileuploads_index',
            title: 'Upload a file'
            activeMenuItem: '/fileuploads'
    )