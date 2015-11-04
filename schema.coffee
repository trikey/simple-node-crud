Schema =
    posts:
        id:
            type: 'increments', nullable: false, primary: true
        title:
            type: 'string', maxlength: 150, nullable: false
        html:
            type: 'text', fieldtype: 'text', nullable: false
        created_at:
            type: 'dateTime', nullable: false
        updated_at:
            type: 'dateTime', nullable: true

module.exports = Schema