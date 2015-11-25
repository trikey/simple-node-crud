Schema =
    posts:
        id:
            type: 'increments', nullable: false, primary: true
        title:
            type: 'string', maxlength: 150, nullable: false
        html:
            type: 'text', fieldtype: 'text', nullable: false
        created_at:
            type: 'dateTime', nullable: true
        updated_at:
            type: 'dateTime', nullable: true
    users:
        id:
            type: 'increments', nullable: false, primary: true
        username:
            type: 'string', maxlength: 150, nullable: false
        password:
            type: 'string', maxlength: 150, nullable: false
        is_admin:
            type: 'integer', nullable: false
        created_at:
            type: 'dateTime', nullable: false
        updated_at:
            type: 'dateTime', nullable: true

module.exports = Schema