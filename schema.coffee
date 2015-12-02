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

    groups:
        id:
            type: 'increments', nullable: false, primary: true
        title:
            type: 'string', maxlength: 150, nullable: false
        created_at:
            type: 'dateTime', nullable: false
        updated_at:
            type: 'dateTime', nullable: true

    user_in_groups:
        id:
            type: 'increments', nullable: false, primary: true
        user_id:
            type: 'integer', nullable: false, unsigned: true, references: 'users.id'
        group_id:
            type: 'integer', nullable: false, unsigned: true, references: 'groups.id'
        created_at:
            type: 'dateTime', nullable: false
        updated_at:
            type: 'dateTime', nullable: true

module.exports = Schema